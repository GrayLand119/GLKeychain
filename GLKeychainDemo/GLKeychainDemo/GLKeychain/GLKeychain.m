//
//  GLKeychain.m
//  GLKeychainDemo
//
//  Created by GrayLand on 2017/11/21.
//  Copyright © 2017年 BodyPlus. All rights reserved.
//

#import "GLKeychain.h"
#import <Security/Security.h>

@interface GLKeychain ()

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

@property (nonatomic, strong) NSString *keychainItemIdentifier;

@end

@implementation GLKeychain

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static GLKeychain *manager;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[GLKeychain alloc] init];
        }
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupKeyChain];
    }
    return self;
}

#pragma mark - Public

- (void)setupKeyChain {
    
    NSString *bundleIdentifer = [[NSBundle mainBundle] bundleIdentifier];
    [self setupKeychainWithIdentifier:bundleIdentifer];
    
}

- (void)setupKeychainWithIdentifier:(NSString *)identifier {
    
    _keychainItemIdentifier = identifier;
    
    OSStatus keychainErr = noErr;
    // Set up the keychain search dictionary:
    _genericPasswordQuery = [[NSMutableDictionary alloc] init];
    // This keychain item is a generic password.
    [_genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                              forKey:(__bridge id)kSecClass];
    // The kSecAttrGeneric attribute is used to store a unique string that is used
    // to easily identify and find this keychain item. The string is first
    // converted to an NSData object:
    NSData *identifierData = [_keychainItemIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keychainItemID = [NSData dataWithBytes:identifierData.bytes
                                            length:identifierData.length];
    [_genericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    // Return the attributes of the first match only:
    [_genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    // Return the attributes of the keychain item (the password is
    //  acquired in the secItemFormatToDictionary: method):
    [_genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue
                              forKey:(__bridge id)kSecReturnAttributes];
    
    // Initialize the dictionary used to hold return data from the keychain:
    CFMutableDictionaryRef outDictionary = nil;
    // If the keychain item exists, return the attributes of the item:
    keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                                      (CFTypeRef *)&outDictionary);
    if (keychainErr == noErr) {
        // Convert the data dictionary into the format used by the view controller:
        self.keychainData = [self secItemFormatToDictionary:(__bridge_transfer NSMutableDictionary *)outDictionary];
    } else if (keychainErr == errSecItemNotFound) {
        // Put default values into the keychain if no matching
        // keychain item is found:
        [self resetKeychainItem];
        if (outDictionary) CFRelease(outDictionary);
    } else {
        // Any other error is unexpected.
        NSAssert(NO, @"Serious error.\n");
        if (outDictionary) CFRelease(outDictionary);
    }
    
    [self changeToAccount:@"GLKeychainAccountDefault"];
    [self changeToService:@"GLKeychainServiceDefault"];
}

- (void)changeToAccount:(NSString *)account {
    _currentAccount = account;
    [self gl_setObject:_currentAccount forKeyType:GLKeychainKeyTypeAcctount];
}

- (void)changeToService:(NSString *)service {
    _currentService = service;
    [self gl_setObject:_currentService forKeyType:GLKeychainKeyTypeService];
}

- (NSString *)readPassword {
    return [self gl_objectForKeyType:GLKeychainKeyTypePassword];
}

- (void)savePassword:(NSString *)password {
    [self gl_setObject:password forKeyType:GLKeychainKeyTypePassword];
}

- (void)gl_setObject:(id)object forKeyType:(GLKeychainKeyType)keyType {
    
    if (object == nil) return;
    
    NSString *keyStr = [self keyWithKeyType:keyType];
    id currentObject = [_keychainData objectForKey:keyStr];
    if (![currentObject isEqual:object]) {
        [_keychainData setObject:object forKey:keyStr];
        [self writeToKeychain];
    }
}

- (id)gl_objectForKeyType:(GLKeychainKeyType)keyType {
    NSString *keyStr = [self keyWithKeyType:keyType];
    return [_keychainData objectForKey:keyStr];
}

- (NSString *)keyWithKeyType:(GLKeychainKeyType)keyType {
    NSString *keyStr = nil;
    switch (keyType) {
        case GLKeychainKeyTypeItemLabel: keyStr = (__bridge id)kSecAttrLabel;break;
        case GLKeychainKeyTypeItemDescription: keyStr = (__bridge id)kSecAttrDescription;break;
        case GLKeychainKeyTypeAcctount: keyStr = (__bridge id)kSecAttrAccount;break;
        case GLKeychainKeyTypeService: keyStr = (__bridge id)kSecAttrService;break;
        case GLKeychainKeyTypeComment: keyStr = (__bridge id)kSecAttrComment;break;
        case GLKeychainKeyTypePassword: keyStr = (__bridge id)kSecValueData;break;
        default:
            NSLog(@"keyWithKeyType: unknow key, the key must be one of GLKeychainKeyType");
            break;
    }
    return keyStr;
}

// Reset the values in the keychain item, or create a new item if it
// doesn't already exist:
- (void)resetKeychainItem {
    
    if (!_keychainData) //Allocate the keychainData dictionary if it doesn't exist yet.
    {
        self.keychainData = [[NSMutableDictionary alloc] init];
    }
    else if (_keychainData)
    {
        // Format the data in the keychainData dictionary into the format needed for a query
        //  and put it into tmpDictionary:
        NSMutableDictionary *tmpDictionary =
        [self dictionaryToSecItemFormat:_keychainData];
        // Delete the keychain item in preparation for resetting the values:
        OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)tmpDictionary);
        NSAssert(errorcode == noErr, @"Problem deleting current keychain item." );
    }
    
    // Default generic data for Keychain Item:
    [_keychainData setObject:@"Item label" forKey:(__bridge id)kSecAttrLabel];
    [_keychainData setObject:@"Item description" forKey:(__bridge id)kSecAttrDescription];
    [_keychainData setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
    [_keychainData setObject:@"Service" forKey:(__bridge id)kSecAttrService];
    [_keychainData setObject:@"Your comment here." forKey:(__bridge id)kSecAttrComment];
    [_keychainData setObject:@"password" forKey:(__bridge id)kSecValueData];
}


#pragma mark - Private

// Implement the dictionaryToSecItemFormat: method, which takes the attributes that
// you want to add to the keychain item and sets up a dictionary in the format
// needed by Keychain Services:
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert {
    
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for a keychain item search.
    
    // Create the return dictionary:
    NSMutableDictionary *returnDictionary =
    [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the keychain item class and the generic attribute:
    NSData *identifierData = [_keychainItemIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keychainItemID = [NSData dataWithBytes:identifierData.bytes
                                            length:identifierData.length];
    [returnDictionary setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Convert the password NSString to NSData to fit the API paradigm:
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding]
                         forKey:(__bridge id)kSecValueData];
    return returnDictionary;
}

// Implement the secItemFormatToDictionary: method, which takes the attribute dictionary
//  obtained from the keychain item, acquires the password from the keychain, and
//  adds it to the attribute dictionary:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert {
    
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for the keychain item.
    
    // Create a return dictionary populated with the attributes:
    NSMutableDictionary *returnDictionary = [NSMutableDictionary
                                             dictionaryWithDictionary:dictionaryToConvert];
    
    // To acquire the password data from the keychain item,
    // first add the search key and class attribute required to obtain the password:
    [returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Then call Keychain Services to get the password:
    CFDataRef passwordData = NULL;
    OSStatus keychainError = noErr; //
    keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary,
                                        (CFTypeRef *)&passwordData);
    if (keychainError == noErr) {
        
        // Remove the kSecReturnData key; we don't need it anymore:
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
        
        // Convert the password to an NSString and add it to the return dictionary:
        NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)passwordData bytes]
                                                      length:[(__bridge NSData *)passwordData length] encoding:NSUTF8StringEncoding];
        [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
    }
    // Don't do anything if nothing is found.
    else if (keychainError == errSecItemNotFound) {
        NSAssert(NO, @"Nothing was found in the keychain.\n");
        if (passwordData) CFRelease(passwordData);
    }
    // Any other error is unexpected.
    else {
        NSAssert(NO, @"Serious error.\n");
        if (passwordData) CFRelease(passwordData);
    }
    
    return returnDictionary;
}

// Implement the writeToKeychain method, which is called by the mySetObject routine,
//   which in turn is called by the UI when there is new data for the keychain. This
//   method modifies an existing keychain item, or--if the item does not already
//   exist--creates a new keychain item with the new attribute value plus
//  default values for the other attributes.
- (void)writeToKeychain {
    
    CFDictionaryRef attributes      = nil;
    NSMutableDictionary *updateItem = nil;
    
    // If the keychain item already exists, modify it:
    if (SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                            (CFTypeRef *)&attributes) == noErr) {
        
        // First, get the attributes returned from the keychain and add them to the
        // dictionary that controls the update:
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)attributes];
        
        // Second, get the class value from the generic password query dictionary and
        // add it to the updateItem dictionary:
        [updateItem setObject:[_genericPasswordQuery objectForKey:(__bridge id)kSecClass]
                       forKey:(__bridge id)kSecClass];
        
        // Finally, set up the dictionary that contains new values for the attributes:
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:_keychainData];
        //Remove the class--it's not a keychain attribute:
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
        
        // You can update only a single keychain item at a time.
        OSStatus errorcode = SecItemUpdate(
                                           (__bridge CFDictionaryRef)updateItem,
                                           (__bridge CFDictionaryRef)tempCheck);
        NSAssert(errorcode == noErr, @"Couldn't update the Keychain Item." );
    }
    else {
        // No previous item found; add the new item.
        // The new value was added to the keychainData dictionary in the mySetObject routine,
        // and the other values were added to the keychainData dictionary previously.
        // No pointer to the newly-added items is needed, so pass NULL for the second parameter:
        OSStatus errorcode = SecItemAdd(
                                        (__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:_keychainData],
                                        NULL);
        NSAssert(errorcode == noErr, @"Couldn't add the Keychain Item." );
        if (attributes) CFRelease(attributes);
    }
}

@end
