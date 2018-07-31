require 'optparse'
require 'shellwords'
require 'pathname'
class ShellExecutor
	@@dry_run = false
	class << self
		# setup
		def setup (dry_run = false)
			@@dry_run = dry_run
		end

		def dry?
			puts "Condition statement is #{@@dry_run.to_s}"
			@@dry_run
		end

		def run_command_line(line)
			puts "I will perform \n <#{line}>"
			if dry?
				puts "I am on dry run!"
			else
				# if run
				result = %x(#{line})
				puts "result is:" + result.to_s
				if $? != 0
					puts "I fall down on < #{result} >\n! because of < #{$?} >"
					exit($?)
				end
				result
			end
		end
	end
end

class KeysGenerator
	module FileFormatsModule
		def only_name(name)
			# remove extension
			Pathname.new(name).basename
		end
		def to_plain_text(name)
			self.only_name(name).sub_ext('.txt')
		end
		def to_p12(name)
			# remove extension
			# add .p12
			self.only_name(name).sub_ext('.p12')
		end
		def to_certificate_request(name)
			# remove extension
			# add .csr
			self.only_name(name).sub_ext('.csr')
		end
		def to_certificate(name, format = '.cer')
			# remove extension
			# add .cer
			self.only_name(name).sub_ext(format)
		end
		def to_pem(name)
			# remove extension
			# add .pem
			self.only_name(name).sub_ext('.pem')
		end
	end
	class FileFormats
		class << self
			include FileFormatsModule
		end
		attr_accessor :name
		def initialize(name)
			self.name = @name
		end
		def valid?
			!self.name.nil?
		end
		def to_p12
			self.class.to_p12(self.name)
		end
		def to_certificate_requets
			self.class.to_certificate_request(self.name)
		end
		def to_certificate
			self.class.to_certificate(self.name)
		end
		def to_pem
			self.class.to_pem(self.name)
		end
	end
	attr_accessor :curve_name, :secret
	def initialize(secret = 'secret')
		self.secret = secret
	end

	module Generating
		def default_subject
			{
				"C": "GB",
				"ST": "London",
				"L": "London",
				"O": "Global Security",
				"OU": "IT Department",
				"CN": "example.com"
			}
		end

		def key_and_value_or_empty(key, value, delimiter, empty = -> (v){ v.nil? || v.empty?})
			the_empty = empty #empty || -> (v){ v.nil? || v.empty?}
			{key => value}.reject{|k,v| the_empty.call(v)}.collect{|k,v| "#{k}#{delimiter}#{v}"}.join('')
		end

		def subject_value_from_subject(subject = {})
			value = subject.collect{|k,v| "/#{k}=#{v}"}.join('')
			value
		end

		def subject_key_and_value_from_subject(subject = {})
			value = subject_value_from_subject(subject)
			{'-subj': value}.reject{|k,v| v.empty?}.collect{|k,v| "#{k} \"#{v}\""}.join('')
		end

		def tool
			%q(openssl)
		end
		def suppress_prompt(command)
			%Q(echo '#{secret}' | #{command})
		end
		def generate_key(curve_name, name)
			%Q(#{tool} ecparam -name #{curve_name} -genkey -noout -out #{name})
		end

		# output keys
		def output_key(access, generated_key_name, name)
			%Q(#{tool} #{access == 'private' ? '' : '-pubout' } -in #{generated_key_name} -out #{name} < echo "#{secret}")
		end
		def output_public_key(generated_key_name, name)
			output_key('public', generated_key_name, name)
		end
		def output_private_key(generated_key_name, name)
			output_key('private', generated_key_name, name)
		end

		def export_public_key(private_key_pem, public_key_pem)
			%Q(#{tool} ec -in #{private_key_pem} -pubout -out #{public_key_pem})
			#openssl ec -in ec256-private.pem -pubout -out ec256-public.pem
		end

		# with prompt?
		def output_certificate_request(private_key_pem, certificate_request, subject = {})
			subject_key_value = subject_key_and_value_from_subject(subject)
			%Q(#{tool} req -new -key #{private_key_pem} -out #{certificate_request} #{subject_key_value})
			# openssl req -new -key private_1.pem -out cert_1.csr
		end

		def output_certificate(certificate_request, private_key_pem, certificate)
			%Q(#{tool} x509 -req -in #{certificate_request} -signkey #{private_key_pem} -out #{certificate})
			# openssl x509 -req -in cert_1.csr -signkey private_1.pem -out cert_1.cer
		end
		def output_p12(certificate, private_key_pem, p12_name, password_file)
			# replace name's extension by p12
			# private_key_pem.pem
			# certificate.crt or certificate.cer
			# p12_name.p12
			password_file_content = %Q("$(cat #{password_file})")
			the_password_key_value = key_and_value_or_empty('-passout pass:', password_file_content, '')
			%Q(#{tool} pkcs12 -export -in #{certificate} -inkey #{private_key_pem} -out #{p12_name} #{the_password_key_value})
		end
		def output_password(file, password = 'password')
			%Q(echo "#{password}" > #{file})
		end
	end

	class << self
		include Generating
	end

	def generated_by_curve
		# curve name only?
		curve_name = self.curve_name
		generated(curve_name, "#{curve_name}-private", "#{curve_name}-public", "#{curve_name}", "#{curve_name}", "#{curve_name}", "#{curve_name}")
	end

	def generated(curve_name, private_key_pem, public_key_pem, certificate_request, certificate, p12, p12_password)
		the_private_key_pem ||= FileFormats.to_pem private_key_pem
		the_public_key_pem ||= FileFormats.to_pem public_key_pem
		the_certificate_request ||= FileFormats.to_certificate_request certificate_request
		the_certificate ||= FileFormats.to_certificate certificate, '.pem'
		the_p12 ||= FileFormats.to_p12 p12
		the_p12_password ||= FileFormats.to_plain_text p12_password

		[
			self.class.generate_key(curve_name, the_private_key_pem),
			self.class.export_public_key(the_private_key_pem, the_public_key_pem),
			self.class.output_certificate_request(the_private_key_pem, the_certificate_request, self.class.default_subject),
			self.class.output_certificate(the_certificate_request, the_private_key_pem, the_certificate),
			self.class.output_password(the_p12_password),
			self.class.output_p12(the_certificate, the_private_key_pem, the_p12, the_p12_password)
		]
	end
end

class MainWork
	class << self
		def work(arguments)
			the_work = new
			the_work.work(the_work.parse_options(arguments))
		end
	end
	def fix_options(the_options)
		options = the_options
		options[:result_directory] ||= '../Tests/Resources/Certs/'
		if options[:test]
			options[:generated_key_name] ||= 'generated'
			options[:private_key_name] ||= 'private'
			options[:public_key_name] ||= 'public'
		end
		options
	end
	def work(options = {})
		options = fix_options(options)

		if options[:inspection]
			puts "options are: #{options}"
		end

		ShellExecutor.setup options[:dry_run]

		generator = KeysGenerator.new
		generator.curve_name = options[:curve_name]

		generator.generated_by_curve.each do |command|
			ShellExecutor.run_command_line command
		end
		 #KeyParameters.new(options[:algorithm_type], options[:key_length])
		# [
		# 	key_parameters.generate_key(options[:generated_key_name]),
		# 	key_parameters.output_private_key(options[:generated_key_name], options[:private_key_name]),
		# 	key_parameters.output_public_key(options[:generated_key_name], options[:public_key_name])
		# ].map do |command|
		# 	key_parameters.suppress_prompt command
		# end
		# .each do |command|
		# 	ShellExecutor.run_command_line command
		# end
	end
	def help_message(options)
		# %x[rdoc $0]
		# not ok
		puts <<-__HELP__

		#{options.help}

		this script will help you generate keys.

		First, it takes arguments:
		[needed] <-f DIRECTORY>: directory where you will gather files
		[not needed] <-r DIRECTORY>: directory where files will be placed


		---------------
		Usage:
		---------------
		#{$0} -t ../Tests/Resources/Certs/

		__HELP__
	end
	def parse_options(arguments)
		options = {}
		OptionParser.new do |opts|
			opts.banner = "Usage: #{$0} [options]"
			opts.on('-o', '--output_directory DIRECTORY', 'Output Directory') {|v| options[:output_directory] = v}
			opts.on('-t', '--test', 'Test option') {|v| options[:test] = v}
			opts.on('-c', '--curve_name CURVE_NAME', 'Curve name') {|v| options[:curve_name] = v}
			opts.on('-g', '--generated_key_name NAME', 'Generated key name') {|v| options[:generated_key_name] = v}
			opts.on('-r', '--private_key_name NAME', 'Private Key Name') {|v| options[:private_key_name] = v}
			opts.on('-u', '--public_key_name NAME', 'Public Key Name') {|v| options[:public_key_name] = v}
			# opts.on('-l', '--log_level LEVEL', 'Logger level of warning') {|v| options[:log_level] = v}
			# opts.on('-o', '--output_log OUTPUT', 'Logger output stream') {|v| options[:output_stream] = v}
			opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
			opts.on('-i', '--inspection', 'Inspection of all items, like tests'){|v| options[:inspection] = v}

			# help
			opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit()}
		end.parse!(arguments)
		options
	end
end

MainWork.work(ARGV)
