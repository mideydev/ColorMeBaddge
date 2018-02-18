#import "CMBBrightnessListController.h"

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
	[self setPreferenceValue:[@(CMB_DEFAULT_COLOR_SPACE_TYPE) stringValue] specifier:[self specifierForID:@"CMBColorSpaceType"]];
	[self setPreferenceValue:@(CMB_DEFAULT_BRIGHTNESS_THRESHOLD) specifier:[self specifierForID:@"CMBBrightnessThreshold"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE) stringValue] specifier:[self specifierForID:@"CMBBadgeColorAdjustmentType"]];
}

@end

// vim:ft=objc
