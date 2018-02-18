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
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBBadgeBorderColor"];
	[self setPreferenceValue:@CMB_DEFAULT_BADGE_BORDER_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBBadgeBorderType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_BADGE_BORDER_TYPE) stringValue] specifier:specifier];

	specifier = [self specifierForID:@"CMBBadgeBorderWidth"];
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_BORDER_WIDTH) specifier:specifier];

	specifier = [self specifierForID:@"CMBBadgeBordersEnabled"];
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_BORDERS_ENABLED) specifier:specifier];
}

@end

// vim:ft=objc
