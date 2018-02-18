#import <Preferences/PSSpecifier.h>
#import "CMBAppsListController.h"
#import "CMBColorPickerViewController.h"
#import "CMBColorPickerCell.h"
#import "UIColor+HRColorPickerHexColor.h"
#import "../CMBPreferences.h"

@implementation CMBAppsListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeAppsPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBAppBadgeBackgroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBAppBadgeBackgroundType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE) stringValue] specifier:specifier];

	specifier = [self specifierForID:@"CMBAppBadgeForegroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBAppBadgeForegroundType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE) stringValue] specifier:specifier];
}

@end

// vim:ft=objc
