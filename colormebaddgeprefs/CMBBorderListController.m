#import "CMBBorderListController.h"

@implementation CMBBorderListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeBorderPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_BORDERS_ENABLED) specifier:[self specifierForID:@"CMBBadgeBordersEnabled"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_BADGE_BORDER_TYPE) stringValue] specifier:[self specifierForID:@"CMBBadgeBorderType"]];
	[self setPreferenceValue:@CMB_DEFAULT_BADGE_BORDER_COLOR specifier:[self specifierForID:@"CMBBadgeBorderColor"]];
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_BORDER_WIDTH) specifier:[self specifierForID:@"CMBBadgeBorderWidth"]];
}

@end

// vim:ft=objc
