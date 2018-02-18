#import <Preferences/PSSpecifier.h>
#import "CMBBrightnessListController.h"
#import "../CMBPreferences.h"

@implementation CMBBrightnessListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeBrightnessPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBBadgeColorAdjustmentType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE) stringValue] specifier:specifier];

	specifier = [self specifierForID:@"CMBBrightnessThreshold"];
	[self setPreferenceValue:@(CMB_DEFAULT_BRIGHTNESS_THRESHOLD) specifier:specifier];

	specifier = [self specifierForID:@"CMBColorSpaceType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_COLOR_SPACE_TYPE) stringValue] specifier:specifier];
}

@end

// vim:ft=objc
