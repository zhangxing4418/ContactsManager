//
// ContactsManager.m
// ContactViewController
//
// Created by Ziv on 16/10/17.
// Copyright © 2016年 Ziv. All rights reserved.
//

#import "ContactsManager.h"
@import ContactsUI;
@import AddressBookUI;
#import "SDK.h"
#import "BeanUtils.h"
#import "CocoaUtils.h"
#import <BlocksKit.h>

NSString *const CMContactNamePrefixKey = @"namePrefix";
NSString *const CMContactGivenNameKey = @"givenName";
NSString *const CMContactMiddleNameKey = @"middleName";
NSString *const CMContactFamilyNameKey = @"familyName";
NSString *const CMContactNameSuffixKey = @"nameSuffix";
NSString *const CMContactNicknameKey = @"nickname";
NSString *const CMContactPhoneticGivenNameKey = @"phoneticGivenName";
NSString *const CMContactPhoneticMiddleNameKey = @"phoneticMiddleName";
NSString *const CMContactPhoneticFamilyNameKey = @"phoneticFamilyName";
NSString *const CMContactOrganizationNameKey = @"organizationName";
NSString *const CMContactDepartmentNameKey = @"departmentName";
NSString *const CMContactJobTitleKey = @"jobTitle";
NSString *const CMContactBirthdayKey = @"birthday";
NSString *const CMContactNonGregorianBirthdayKey = @"nonGregorianBirthday";
NSString *const CMContactNoteKey = @"note";
NSString *const CMContactImageKey = @"image";;
NSString *const CMContactThumbnailImageKey = @"thumbnailImage";;
NSString *const CMContactImageAvailableKey = @"imageAvailable";;
NSString *const CMContactPhoneNumbersKey = @"phoneNumbers";
NSString *const CMContactEmailAddressesKey = @"emailAddresses";
NSString *const CMContactPostalAddressesKey = @"postalAddresses";
NSString *const CMContactDatesKey = @"dates";
NSString *const CMContactUrlAddressesKey = @"urlAddresses";
NSString *const CMContactRelationsKey = @"contactRelations";
NSString *const CMContactSocialProfilesKey = @"socialProfiles";
NSString *const CMContactInstantMessageAddressesKey = @"instantMessageAddresses";

@implementation CMPostalAddress
@end

@implementation CMSocialProfile
@end

@implementation CMInstantMessageAddress
@end

@implementation CMContactProperty
@end

@interface CMContact ()
@property (nonatomic, strong) NSString *fullName;
@end

@implementation CMContact
@end

@interface ContactsManager () <CNContactPickerDelegate, ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSArray *displayedPropertyKeys;
@property (nonatomic, copy) void (^completion) (id contactOrProperty);
@end

@implementation ContactsManager

#pragma mark - Public

+ (void)displayedPropertyKeys:(NSArray *)displayedPropertyKeys completion:(void (^) (id contactOrProperty))completion {
	ContactsManager *manager = [ContactsManager sharedManager];
	manager.displayedPropertyKeys = displayedPropertyKeys;
	manager.completion = completion;
	[manager show];
}

+ (NSString *)localizedStringForKey:(id)key {
	if (NSClassFromString(@"CNContactPickerViewController")) {
		return [CNContact localizedStringForKey:key];
	} else if (NSClassFromString(@"ABPeoplePickerNavigationController")) {
		return (__bridge_transfer NSString *)ABPersonCopyLocalizedPropertyName([key intValue]);
	}
	return nil;
}

+ (BOOL)authorizeContacts {
	__block BOOL access = NO;
	if (NSClassFromString(@"CNContactPickerViewController")) {
		CNAuthorizationStatus statu = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
		if (statu == CNAuthorizationStatusNotDetermined) {
			CNContactStore *contactStore = [[CNContactStore alloc] init];
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			[contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
				if (granted) {
					access = YES;
				}
				dispatch_semaphore_signal(semaphore);
			}];
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		} else if (statu == CNAuthorizationStatusAuthorized) {
			access = YES;
		}
	} else if (NSClassFromString(@"ABPeoplePickerNavigationController")) {
		ABAuthorizationStatus statu = ABAddressBookGetAuthorizationStatus();
		if (statu == kABAuthorizationStatusNotDetermined) {
			ABAddressBookRef addressBook = ABAddressBookCreate();
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
				if (granted) {
					access = YES;
				}
				dispatch_semaphore_signal(semaphore);
			});
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			CFRelease(addressBook);
		} else if (statu == kABAuthorizationStatusAuthorized) {
			access = YES;
		}
	}
	return access;
}

#pragma mark - Property

- (UIViewController *)viewController {
	if (!_viewController) {
		if (NSClassFromString(@"CNContactPickerViewController")) {
			CNContactPickerViewController *contactVC = [[CNContactPickerViewController alloc] init];
			contactVC.delegate = self;
			contactVC.predicateForEnablingContact = [NSPredicate predicateWithValue:TRUE];
			_viewController = contactVC;
		} else if (NSClassFromString(@"ABPeoplePickerNavigationController")) {
			ABPeoplePickerNavigationController *pickerController = [[ABPeoplePickerNavigationController alloc] init];
			pickerController.peoplePickerDelegate = self;
			pickerController.predicateForEnablingPerson = [NSPredicate predicateWithValue:TRUE];
			_viewController = pickerController;
		}
	}
	return _viewController;
}

#pragma mark - Private

+ (instancetype)sharedManager {
	static dispatch_once_t onceToken;
	static ContactsManager *manager;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

+ (NSDictionary *)transformCNContactKey {
	return @{CMContactNamePrefixKey : CNContactNamePrefixKey, CMContactGivenNameKey : CNContactGivenNameKey, CMContactMiddleNameKey : CNContactMiddleNameKey, CMContactFamilyNameKey : CNContactFamilyNameKey, CMContactNameSuffixKey : CNContactNameSuffixKey, CMContactNicknameKey : CNContactNicknameKey, CMContactPhoneticGivenNameKey : CNContactPhoneticGivenNameKey, CMContactPhoneticMiddleNameKey : CNContactPhoneticMiddleNameKey, CMContactPhoneticFamilyNameKey : CNContactPhoneticFamilyNameKey, CMContactOrganizationNameKey : CNContactOrganizationNameKey, CMContactDepartmentNameKey : CNContactDepartmentNameKey, CMContactJobTitleKey : CNContactJobTitleKey, CMContactBirthdayKey : CNContactBirthdayKey, CMContactNonGregorianBirthdayKey : CNContactNonGregorianBirthdayKey, CMContactNoteKey : CNContactNoteKey, CMContactImageKey : CNContactImageDataKey, CMContactThumbnailImageKey : CNContactThumbnailImageDataKey, CMContactImageAvailableKey : CNContactImageDataAvailableKey, CMContactPhoneNumbersKey : CNContactPhoneNumbersKey, CMContactEmailAddressesKey : CNContactEmailAddressesKey, CMContactPostalAddressesKey : CNContactPostalAddressesKey, CMContactDatesKey : CNContactDatesKey, CMContactUrlAddressesKey : CNContactUrlAddressesKey, CMContactRelationsKey : CNContactRelationsKey, CMContactSocialProfilesKey : CNContactSocialProfilesKey, CMContactInstantMessageAddressesKey : CNContactInstantMessageAddressesKey};
}

+ (NSDictionary *)transformABPropertyID {
	// no image, thumbnailImage, imageAvailable
	return @{CMContactNamePrefixKey : @(kABPersonPrefixProperty), CMContactGivenNameKey : @(kABPersonFirstNameProperty), CMContactMiddleNameKey : @(kABPersonMiddleNameProperty), CMContactFamilyNameKey : @(kABPersonLastNameProperty), CMContactNameSuffixKey : @(kABPersonSuffixProperty), CMContactNicknameKey : @(kABPersonNicknameProperty), CMContactPhoneticGivenNameKey : @(kABPersonFirstNamePhoneticProperty), CMContactPhoneticMiddleNameKey : @(kABPersonMiddleNamePhoneticProperty), CMContactPhoneticFamilyNameKey : @(kABPersonLastNamePhoneticProperty), CMContactOrganizationNameKey : @(kABPersonOrganizationProperty), CMContactDepartmentNameKey : @(kABPersonDepartmentProperty), CMContactJobTitleKey : @(kABPersonJobTitleProperty), CMContactBirthdayKey : @(kABPersonBirthdayProperty), CMContactNonGregorianBirthdayKey : @(kABPersonAlternateBirthdayProperty), CMContactNoteKey : @(kABPersonNoteProperty), CMContactPhoneNumbersKey : @(kABPersonPhoneProperty), CMContactEmailAddressesKey : @(kABPersonEmailProperty), CMContactPostalAddressesKey : @(kABPersonAddressProperty), CMContactDatesKey : @(kABPersonDateProperty), CMContactUrlAddressesKey : @(kABPersonURLProperty), CMContactRelationsKey : @(kABPersonRelatedNamesProperty), CMContactSocialProfilesKey : @(kABPersonSocialProfileProperty), CMContactInstantMessageAddressesKey : @(kABPersonInstantMessageProperty)};
}

+ (BOOL)hasLabeledValuesForKey:(id)key {
	return [@[CMContactPhoneNumbersKey, CMContactEmailAddressesKey, CMContactPostalAddressesKey, CMContactUrlAddressesKey, CMContactRelationsKey, CMContactSocialProfilesKey, CMContactInstantMessageAddressesKey, CMContactDatesKey] containsObject: key];
}

- (void)configContact {
	if (NSClassFromString(@"CNContactPickerViewController")) {
		CNContactPickerViewController *contactVC = self.viewController;
		contactVC.displayedPropertyKeys = [self.displayedPropertyKeys bk_map:^id (id obj) {
			return [ContactsManager transformCNContactKey][obj];
		}];
		contactVC.predicateForSelectionOfContact = [NSPredicate predicateWithValue:[self isSelectionOfContact]];
	} else if (NSClassFromString(@"ABPeoplePickerNavigationController")) {
		ABPeoplePickerNavigationController *pickerController = self.viewController;
		pickerController.displayedProperties = [self.displayedPropertyKeys bk_map:^id (id obj) {
			return [ContactsManager transformABPropertyID][obj];
		}];
		pickerController.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:[self isSelectionOfContact]];
	}
}

- (void)show {
	[self configContact];
	UIViewController *this = [CocoaUtils topMostViewController];
	[this.view endEditing:YES];
	[this presentViewController:self.viewController animated:YES completion:nil];
}

- (void)dismiss {
	self.displayedPropertyKeys = nil;
	self.completion = nil;
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
	if (NSClassFromString(@"CNContactPickerViewController")) {
	} else if (NSClassFromString(@"ABPeoplePickerNavigationController")) {
		self.viewController = nil;
	}
}

- (BOOL)isSelectionOfContact {
	return [self.displayedPropertyKeys bk_any:^BOOL (id obj) {
		return [ContactsManager hasLabeledValuesForKey:obj];
	}] ? FALSE : TRUE;
}

- (CMContact *)_contactForCNContact:(CNContact *)contact {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	CMContact *cmContact = [[CMContact alloc] init];
	for (id key in self.displayedPropertyKeys) {
		NSString *property = [ContactsManager transformCNContactKey][key];
		id value = [contact valueForKey:property];
		if ([@[CMContactImageKey, CMContactThumbnailImageKey] containsObject:key]) {
			[cmContact setValue:[UIImage imageWithData:value] forKey:key];
		} else if ([@[CMContactBirthdayKey, CMContactNonGregorianBirthdayKey] containsObject:key]) {
			[cmContact setValue:[calendar dateFromComponents:value] forKey:key];
		} else if ([ContactsManager hasLabeledValuesForKey:key]) {
			[cmContact setValue:[value bk_map:^id (id obj) {
				return [self _contactPropertyFromCNObject:obj property:property];
			}] forKey:key];
		} else {
			[cmContact setValue:value forKey:key];
		}
	}
	cmContact.fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
	return cmContact;
}

- (CMContactProperty *)_contactPropertyFromCNObject:(id)object property:(NSString *)property {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	CMContactProperty *cmProperty = [[CMContactProperty alloc] init];
	cmProperty.key = property;
	cmProperty.label = [CNLabeledValue localizedStringForLabel:[object label]];
	if ([property isEqual:CNContactPhoneNumbersKey]) {
		CNPhoneNumber *phoneNumber = [object valueForKey:@"value"];
		cmProperty.value = phoneNumber.stringValue;
	} else if ([property isEqual:CNContactPostalAddressesKey]) {
		CMPostalAddress *postalAddress = [[CMPostalAddress alloc] init];
		[BeanUtils populate:postalAddress properties:[BeanUtils describe:[object valueForKey:@"value"] attributeKeys:[BeanUtils getAttributeKeys:postalAddress.class]]];
		cmProperty.value = postalAddress;
	} else if ([property isEqual:CNContactRelationsKey]) {
		CNContactRelation *contactRelation = [object valueForKey:@"value"];
		cmProperty.value = contactRelation.name;
	} else if ([property isEqual:CNContactSocialProfilesKey]) {
		CMSocialProfile *socialProfile = [[CMSocialProfile alloc] init];
		[BeanUtils populate:socialProfile properties:[BeanUtils describe:[object valueForKey:@"value"] attributeKeys:[BeanUtils getAttributeKeys:socialProfile.class]]];
		cmProperty.value = socialProfile;
	} else if ([property isEqual:CNContactInstantMessageAddressesKey]) {
		CMInstantMessageAddress *instantMessageAddress = [[CMInstantMessageAddress alloc] init];
		[BeanUtils populate:instantMessageAddress properties:[BeanUtils describe:[object valueForKey:@"value"] attributeKeys:[BeanUtils getAttributeKeys:instantMessageAddress.class]]];
		cmProperty.value = instantMessageAddress;
	} else if ([property isEqual:CNContactDatesKey]) {
		cmProperty.value = [calendar dateFromComponents:[object valueForKey:@"value"]];
	} else {
		cmProperty.value = [object valueForKey:@"value"];
	}
	return cmProperty;
}

- (CMContact *)_contactForABRecord:(ABRecordRef)person {
	CMContact *cmContact = [[CMContact alloc] init];
	for (id key in self.displayedPropertyKeys) {
		if ([key isEqual:CMContactImageKey]) {
			cmContact.image = [UIImage imageWithData:(__bridge_transfer NSData *)(ABPersonCopyImageData(person))];
		} else if ([key isEqual:CMContactThumbnailImageKey]) {
			cmContact.thumbnailImage = [UIImage imageWithData:(__bridge_transfer NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail))];
		} else if ([key isEqual:CMContactImageAvailableKey]) {
			cmContact.imageAvailable = ABPersonHasImageData(person);
		} else {
			ABPropertyID property = [[ContactsManager transformABPropertyID][key] intValue];
			if ([ContactsManager hasLabeledValuesForKey:key]) {
				[cmContact setValue:[self _contactPropertyMultiFromABRecord:person property:property] forKey:key];
			} else {
				[cmContact setValue:(__bridge_transfer id)ABRecordCopyValue(person, property) forKey:key];
			}
		}
	}
	if (YES) {
		if (cmContact.givenName.length > 0 && cmContact.familyName.length > 0) {
			NSMutableString *string = [NSMutableString string];
			if (ABPersonGetCompositeNameFormatForRecord(person) == kABPersonCompositeNameFormatFirstNameFirst) {
				[string im_appendString:cmContact.givenName];
				[string im_appendString:(__bridge_transfer NSString *)ABPersonCopyCompositeNameDelimiterForRecord(person)];
				[string im_appendString:cmContact.familyName];
			} else if (ABPersonGetCompositeNameFormatForRecord(person) == kABPersonCompositeNameFormatLastNameFirst) {
				[string im_appendString:cmContact.familyName];
				[string im_appendString:(__bridge_transfer NSString *)ABPersonCopyCompositeNameDelimiterForRecord(person)];
				[string im_appendString:cmContact.givenName];
			}
			cmContact.fullName = [NSString stringWithString:string];
		} else if (cmContact.givenName.length > 0) {
			cmContact.fullName = cmContact.givenName;
		} else if (cmContact.familyName.length > 0) {
			cmContact.fullName = cmContact.familyName;
		}
	}
	return cmContact;
}

- (CMContactProperty *)_contactPropertyFromABRecord:(ABRecordRef)person property:(ABPropertyID)property atIndex:(CFIndex)index {
	ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
	NSString *label = nil;
	CFStringRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, index);
	if (rawLabel) {
		label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(rawLabel);
		CFRelease(rawLabel);
	}
	CMContactProperty *cmProperty = [[CMContactProperty alloc] init];
	cmProperty.key = @(property);
	cmProperty.label = label;
	if (property == kABPersonAddressProperty) {
		NSDictionary *dict = (__bridge_transfer NSDictionary *)(ABMultiValueCopyValueAtIndex(multiValue, index));
		CMPostalAddress *postalAddress = [[CMPostalAddress alloc] init];
		postalAddress.street = dict[(__bridge NSString *)kABPersonAddressStreetKey];
		postalAddress.city = dict[(__bridge NSString *)kABPersonAddressCityKey];
		postalAddress.state = dict[(__bridge NSString *)kABPersonAddressStateKey];
		postalAddress.postalCode = dict[(__bridge NSString *)kABPersonAddressZIPKey];
		postalAddress.country = dict[(__bridge NSString *)kABPersonAddressCountryKey];
		postalAddress.ISOCountryCode = dict[(__bridge NSString *)kABPersonAddressCountryCodeKey];
		cmProperty.value = postalAddress;
	} else if (property == kABPersonSocialProfileProperty) {
		NSDictionary *dict = (__bridge_transfer NSDictionary *)(ABMultiValueCopyValueAtIndex(multiValue, index));
		CMSocialProfile *socialProfile = [[CMSocialProfile alloc] init];
		socialProfile.urlString = dict[(__bridge NSString *)kABPersonSocialProfileURLKey];
		socialProfile.username = dict[(__bridge NSString *)kABPersonSocialProfileUsernameKey];
		socialProfile.userIdentifier = dict[(__bridge NSString *)kABPersonSocialProfileUserIdentifierKey];
		socialProfile.service = dict[(__bridge NSString *)kABPersonSocialProfileServiceKey];
		cmProperty.value = socialProfile;
	} else if (property == kABPersonInstantMessageProperty) {
		NSDictionary *dict = (__bridge_transfer NSDictionary *)(ABMultiValueCopyValueAtIndex(multiValue, index));
		CMInstantMessageAddress *instantMessageAddress = [[CMInstantMessageAddress alloc] init];
		instantMessageAddress.username = dict[(__bridge NSString *)kABPersonInstantMessageUsernameKey];
		instantMessageAddress.service = dict[(__bridge NSString *)kABPersonInstantMessageServiceKey];
		cmProperty.value = instantMessageAddress;
	} else {
		cmProperty.value = (__bridge_transfer id)(ABMultiValueCopyValueAtIndex(multiValue, index));
	}
	CFRelease(multiValue);
	return cmProperty;
}

- (NSArray *)_contactPropertyMultiFromABRecord:(ABRecordRef)person property:(ABPropertyID)property {
	NSMutableArray *array = [NSMutableArray array];
	ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
	CFIndex count = ABMultiValueGetCount(multiValue);
	CFRelease(multiValue);
	for (int index = 0; index < count; ++index) {
		[array addObject:[self _contactPropertyFromABRecord:person property:property atIndex:index]];
	}
	return [NSArray arrayWithArray:array];
}

- (CMContactProperty *)_contactPropertyFromABRecord:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
	CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
	CFRelease(multiValue);
	return [self _contactPropertyFromABRecord:person property:property atIndex:index];
}

#pragma mark - concact picker delegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
	if (self.completion) {
		self.completion([self _contactForCNContact:contact]);
	}
	[self dismiss];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
	if (self.completion) {
		self.completion([self _contactPropertyFromCNObject:contactProperty property:contactProperty.key]);
	}
	[self dismiss];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
	[self dismiss];
}

#pragma mark - people picker navigation controller delegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
	if (self.completion) {
		self.completion([self _contactForABRecord:person]);
	}
	[self dismiss];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	if (self.completion) {
		self.completion([self _contactPropertyFromABRecord:person property:property identifier:identifier]);
	}
	[self dismiss];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismiss];
}

@end
