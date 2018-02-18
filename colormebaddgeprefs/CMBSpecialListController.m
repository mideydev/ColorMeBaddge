#import "CMBSpecialListController.h"

@implementation CMBSpecialListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeSpecialPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBSpecialBadgesBackgroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_SPECIAL_BADGE_BACKGROUND_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBSpecialBadgesEnabled"];
	[self setPreferenceValue:@(CMB_DEFAULT_SPECIAL_BADGES_ENABLED) specifier:specifier];

	specifier = [self specifierForID:@"CMBSpecialBadgesForegroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_SPECIAL_BADGE_FOREGROUND_COLOR specifier:specifier];
}

@end

// vim:ft=objc
