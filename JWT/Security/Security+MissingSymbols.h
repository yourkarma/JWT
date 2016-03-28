#import <Security/Security.h>
#import <TargetConditionals.h>

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
/**
    These symbols are available in the iOS 9.3 SDK and marked as "available in Mac OS X
    10.7 and later", but are unavailable in the Mac headers for unknown reasons. They are
    available in the binary, so adding their symbols like this both compiles and links
    without issue.
 */
extern OSStatus SecKeyRawVerify(
    SecKeyRef           key,
	SecPadding          padding,
	const uint8_t       *signedData,
	size_t              signedDataLen,
	const uint8_t       *sig,
	size_t              sigLen)
    __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_2_0);

extern OSStatus SecKeyRawSign(
    SecKeyRef           key,
	SecPadding          padding,
	const uint8_t       *dataToSign,
	size_t              dataToSignLen,
	uint8_t             *sig,
	size_t              *sigLen)
    __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_2_0);

enum {
    kSecPaddingPKCS1SHA256 = 0x8004,
};
#endif