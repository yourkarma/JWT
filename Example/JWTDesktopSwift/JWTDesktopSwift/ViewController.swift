//
//  ViewController.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 01.10.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

import Cocoa
import JWT
import JWTDesktopSwiftToolkit


// MARK: - Supply JWT Methods
extension ViewController {
    func tokenDataTransferObject() -> TokenDecoder.DataTransferObject {
        let algorithmName = self.algorithmPopUpButton.selectedItem?.title ?? ""
        let secret = self.secretTextField.stringValue
        let secretData: Data? = self.getSecretData
        let isBase64EncodedSecret = self.secretIsBase64EncodedCheckButton.integerValue == 1
        let shouldSkipSignatureVerification = self.signatureVerificationCheckButton.integerValue == 1
        return .init(algorithmName: algorithmName, secret: secret, secretData: secretData, isBase64EncodedSecret: isBase64EncodedSecret, shouldSkipSignatureVerification: shouldSkipSignatureVerification)
    }
    
    func tokenDataTransferObjectShouldCheckSignature() -> TokenDecoder.DataTransferObject {
        var result = self.tokenDataTransferObject()
        result.shouldSkipSignatureVerification = false
        return result
    }
    
    var getSecretData: Data? {
        let secret = self.secretTextField.stringValue
        
        let isBase64Encoded = self.secretIsBase64EncodedCheckButton.integerValue == 1
        guard let result = Data(base64Encoded: secret), isBase64Encoded else {
            self.secretIsBase64EncodedCheckButton.integerValue = 0
            return nil
        }
        
        return result
    }
}

// Refresh UI
extension ViewController {
    // MARK: - Encoded Text View
    func encodedTextAttributes(_ enumerate: (NSRange, [NSAttributedString.Key : Any]) -> ()) {
        let textStorage = self.encodedTextView.textStorage!
        let string = textStorage.string
        let range = NSMakeRange(0, string.count)
        if let attributedString = self.model.appearance.encodedAttributedString(text: string) {
            attributedString.enumerateAttributes(in: range, options: []) { (attributes, range, bool) in
                enumerate(range, attributes)
            }
        }
    }
    
    // MARK: - Refresh UI
    func refreshUI() {
        
        let textStorage = self.encodedTextView.textStorage!;
        let string = textStorage.string
        self.encodedTextAttributes { (range, attributes) in
            textStorage.setAttributes(attributes, range: range)
        }
        
        // We should add an option to skip verification in decoding section.
        // invalid signature doesn't mean that you can't decode JWT.
        
        if let jwtVerified = self.model.decoder.decode(token: string, object: self.tokenDataTransferObjectShouldCheckSignature()) {
            let notVerified = jwtVerified.successResult?.headerAndPayloadDictionary?.isEmpty == true
            self.signatureReactOnVerifiedToken(verified: !notVerified)
        }
        else {
            self.signatureReactOnVerifiedToken(verified: false)
        }
        
        let result = self.model.decoder.decode(token: string, object: self.tokenDataTransferObject())
        
        self.decriptedViewController.resultType = result
    }
    
    func refreshSignature() {
        self.signatureStatusLabel.backgroundColor = self.model.signatureValidation.color
        self.signatureStatusLabel.stringValue = self.model.signatureValidation.title
    }
}

// MARK: - Actions
extension ViewController {
    @objc func popUpButtonValueChanged(sender : AnyClass) {
        self.refreshUI()
    }
    
    @objc func checkBoxState(sender : AnyClass) {
        self.refreshUI()
    }
    func signatureReactOnVerifiedToken(verified: Bool) {
        self.model.signatureValidation = verified ? .valid : .invalid
        self.refreshSignature()
    }
}

extension ViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if (obj.name == NSControl.textDidChangeNotification) {
            let textField = obj.object as! NSTextField
            if textField == self.secretTextField {
                self.refreshUI()
            }
        }
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        self.refreshUI()
    }
//    func textViewDidChangeTypingAttributes(_ notification: Notification) {
//        self.updateEncodedTextAttributes()
//    }
//    func textView(_ textView: NSTextView, shouldChangeTypingAttributes oldTypingAttributes: [String : Any] = [:], toAttributes newTypingAttributes: [NSAttributedString.Key : Any] = [:]) -> [NSAttributedString.Key : Any] {
//        return newTypingAttributes
//    }
    
//    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
//        if (textView == self.encodedTextView) {
////            if let textStore = textView.textStorage {
////                textView.undoManager?.beginUndoGrouping()
////                textStore.replaceCharacters(in: affectedCharRange, with: replacementString!)
////                self.encodedTextAttributes { (range, attributes) in
////                    textStore.setAttributes(attributes, range: range)
////                }
////                textView.undoManager?.endUndoGrouping()
////            }
////            self.refreshUI()
//            return true
//        }
//        return false
//    }
}

// MARK: - EncodingTextViewDelegate
//extension ViewController : NSTextViewDelegate {
//    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
//        if (textView == self.encodedTextView) {
//            if let textStore = textView.textStorage {
//                textStore.replaceCharacters(in: affectedCharRange, with: replacementString!)
//            }
//            self.refreshUI()
//            return false
//        }
//        return false
//    }
//}

class ViewController: NSViewController {
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Properties - Outlets
    @IBOutlet weak var algorithmLabel : NSTextField!
    @IBOutlet weak var algorithmPopUpButton : NSPopUpButton!
    
    @IBOutlet weak var secretLabel : NSTextField!
    @IBOutlet weak var secretTextField : NSTextField!
    @IBOutlet weak var secretIsBase64EncodedCheckButton : NSButton!
    
    @IBOutlet weak var signatureLabel : NSTextField!
    @IBOutlet weak var signatureVerificationCheckButton : NSButton!
    
    
    @IBOutlet weak var encodedTextView : NSTextView!
    @IBOutlet weak var decriptedView : NSView!
    var decriptedViewController : DecriptedViewController!
    
    @IBOutlet weak var signatureStatusLabel : NSTextField!
    
    // MARK: - Model
    var model: Model!
    
    // MARK: - Setup
    func setupModel() {
        self.model = Model()
    }
    
    func setupTop() {
        // top label.
        self.algorithmLabel.stringValue = "Algorithm";
        // pop up button.
        
        self.algorithmPopUpButton.removeAllItems()
        self.algorithmPopUpButton.addItems(withTitles: self.model.availableAlgorithmsNames)
        self.algorithmPopUpButton.target = self
        self.algorithmPopUpButton.action = #selector(ViewController.popUpButtonValueChanged(sender:))
        
        // secretLabel
        self.secretLabel.stringValue = "Secret"
        
        // secretTextField
        self.secretTextField.placeholderString = "Secret"
        self.secretTextField.delegate = self

        // check button
        self.secretIsBase64EncodedCheckButton.title = "is Base64Encoded Secret"
        self.secretIsBase64EncodedCheckButton.integerValue = 0
        self.secretIsBase64EncodedCheckButton.target = self
        self.secretIsBase64EncodedCheckButton.action = #selector(ViewController.checkBoxState(sender:))
        
        // signatureLabel
        self.signatureLabel.stringValue = "Signature"
        
        // signatureVerificationCheckButton
        self.signatureVerificationCheckButton.title = "Skip signature verification"
        self.signatureVerificationCheckButton.integerValue = 0
        self.signatureVerificationCheckButton.target = self
        self.signatureVerificationCheckButton.action = #selector(ViewController.checkBoxState(sender:))
    }
    
    func setupBottom() {
        self.signatureStatusLabel.alignment       = .center
        self.signatureStatusLabel.textColor       = NSColor.white
        self.signatureStatusLabel.drawsBackground = true
        self.refreshSignature()
    }

    func setupEncodingDecodingViews() {
        self.encodedTextView.delegate = self;
    }
    
    func setupDecorations() {
        self.setupTop()
        self.setupBottom()
    }
    
    func setupDecriptedViews() {
        let view = self.decriptedView
        self.decriptedViewController = DecriptedViewController()
        view?.addSubview(self.decriptedViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupModel()
        
        self.setupDecorations()
        self.setupEncodingDecodingViews()
        self.setupDecriptedViews()
        
        self.defaultDataSetup()
    }
    
    func defaultDataSetup(algorithmName: String, secret: String, token: String) {
        // algorithm HS256
        if let index = self.model.availableAlgorithmsNames.firstIndex(where: {
            $0 == algorithmName
        }) {
            self.algorithmPopUpButton.selectItem(at: index)
        }

        // secret
        self.secretTextField.stringValue = secret
        
        // token
        var range = NSRange()
        range.location = 0
        range.length = token.count
        self.encodedTextView.insertText(token, replacementRange: range)

    }
    
    func defaultDataSetup() {
        let seed = DataSeedType.rs256.dataSeed//rs256.dataSeed
        self.defaultDataSetup(algorithmName: seed.algorithmName, secret: seed.secret, token: seed.token)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let view = self.decriptedView else { return }
        
        let subview = self.decriptedViewController.view

        view.translatesAutoresizingMaskIntoConstraints = false
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            subview.leftAnchor.constraint(equalTo: view.leftAnchor),
            subview.rightAnchor.constraint(equalTo: view.rightAnchor),
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

