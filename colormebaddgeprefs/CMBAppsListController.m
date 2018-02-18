#import "CMBAppsListController.h"

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
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE) stringValue] specifier:[self specifierForID:@"CMBAppBadgeBackgroundType"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_BACKGROUND_ADJUSTMENT_TYPE) stringValue] specifier:[self specifierForID:@"CMBAppBadgeBackgroundAdjustmentType"]];
	[self setPreferenceValue:@CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR specifier:[self specifierForID:@"CMBAppBadgeBackgroundColor"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE) stringValue] specifier:[self specifierForID:@"CMBAppBadgeForegroundType"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_APP_BADGE_FOREGROUND_ADJUSTMENT_TYPE) stringValue] specifier:[self specifierForID:@"CMBAppBadgeForegroundAdjustmentType"]];
	[self setPreferenceValue:@CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR specifier:[self specifierForID:@"CMBAppBadgeForegroundColor"]];
}

@end

// vim:ft=objc
