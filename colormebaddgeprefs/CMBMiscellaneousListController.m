#import <Preferences/PSSpecifier.h>
#import "CMBMiscellaneousListController.h"
#import "../CMBPreferences.h"

@implementation CMBMiscellaneousListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeMiscellaneousPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBUseUnmaskedIcons"];
	[self setPreferenceValue:@(CMB_DEFAULT_USE_UNMASKED_ICONS) specifier:specifier];

	specifier = [self specifierForID:@"CMBShowAllBadges"];
	[self setPreferenceValue:@(CMB_DEFAULT_SHOW_ALL_BADGES) specifier:specifier];
}

@end

// vim:ft=objc
