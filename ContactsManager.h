//
// ContactsManager.h
// ContactViewController
//
// Created by Ziv on 16/10/17.
// Copyright © 2016年 Ziv. All rights reserved.
//

@import Foundation;
@import UIKit;
@import Contacts;
@import AddressBook;

FOUNDATION_EXPORT NSString *const CMContactNamePrefixKey;
FOUNDATION_EXPORT NSString *const CMContactGivenNameKey;
FOUNDATION_EXPORT NSString *const CMContactMiddleNameKey;
FOUNDATION_EXPORT NSString *const CMContactFamilyNameKey;
FOUNDATION_EXPORT NSString *const CMContactNameSuffixKey;
FOUNDATION_EXPORT NSString *const CMContactNicknameKey;
FOUNDATION_EXPORT NSString *const CMContactPhoneticGivenNameKey;
FOUNDATION_EXPORT NSString *const CMContactPhoneticMiddleNameKey;
FOUNDATION_EXPORT NSString *const CMContactPhoneticFamilyNameKey;
FOUNDATION_EXPORT NSString *const CMContactOrganizationNameKey;
FOUNDATION_EXPORT NSString *const CMContactDepartmentNameKey;
FOUNDATION_EXPORT NSString *const CMContactJobTitleKey;
FOUNDATION_EXPORT NSString *const CMContactBirthdayKey;
FOUNDATION_EXPORT NSString *const CMContactNonGregorianBirthdayKey;
FOUNDATION_EXPORT NSString *const CMContactNoteKey;
FOUNDATION_EXPORT NSString *const CMContactImageKey;
FOUNDATION_EXPORT NSString *const CMContactThumbnailImageKey;
FOUNDATION_EXPORT NSString *const CMContactImageAvailableKey;
FOUNDATION_EXPORT NSString *const CMContactPhoneNumbersKey;
FOUNDATION_EXPORT NSString *const CMContactEmailAddressesKey;
FOUNDATION_EXPORT NSString *const CMContactPostalAddressesKey;
FOUNDATION_EXPORT NSString *const CMContactDatesKey;
FOUNDATION_EXPORT NSString *const CMContactUrlAddressesKey;
FOUNDATION_EXPORT NSString *const CMContactRelationsKey;
FOUNDATION_EXPORT NSString *const CMContactSocialProfilesKey;
FOUNDATION_EXPORT NSString *const CMContactInstantMessageAddressesKey;

@interface CMPostalAddress : NSObject
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *ISOCountryCode;
@end

@interface CMSocialProfile : NSObject
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userIdentifier;
@property (nonatomic, strong) NSString *service;
@end

@interface CMInstantMessageAddress : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *service;
@end

@interface CMContactProperty : NSObject
@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *label;
@end

@interface CMContact : NSObject

@property (nonatomic, strong) NSString *namePrefix;
@property (nonatomic, strong) NSString *givenName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *nameSuffix;
@property (nonatomic, strong) NSString *nickname;

@property (nonatomic, strong) NSString *phoneticGivenName;
@property (nonatomic, strong) NSString *phoneticMiddleName;
@property (nonatomic, strong) NSString *phoneticFamilyName;

@property (nonatomic, strong) NSString *orgnizationName;
@property (nonatomic, strong) NSString *departmentName;
@property (nonatomic, strong) NSString *jobTitle;

@property (nonatomic, strong) NSString *note;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) BOOL imageAvailable;

@property (nonatomic, strong) NSArray<CMContactProperty *> *phoneNumbers;
@property (nonatomic, strong) NSArray<CMContactProperty *> *emailAddresses;
@property (nonatomic, strong) NSArray<CMContactProperty *> *postalAddresses;
@property (nonatomic, strong) NSArray<CMContactProperty *> *urlAddresses;
@property (nonatomic, strong) NSArray<CMContactProperty *> *contactRelations;
@property (nonatomic, strong) NSArray<CMContactProperty *> *socialProfiles;
@property (nonatomic, strong) NSArray<CMContactProperty *> *instantMessageAddresses;

@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDate *nonGregrianBirthday;
@property (nonatomic, strong) NSArray<CMContactProperty *> *dates;

@property (nonatomic, strong, readonly) NSString *fullName;

@end

@interface ContactsManager : NSObject
+ (BOOL)authorizeContacts;
+ (NSString *)localizedStringForKey:(id)key;
+ (void)displayedPropertyKeys:(NSArray *)displayedPropertyKeys completion:(void (^) (id contactOrProperty))completion;
@end
