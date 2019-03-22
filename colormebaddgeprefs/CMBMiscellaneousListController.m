#import "CMBMiscellaneousListController.h"

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
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_SIZE_ADJUSTMENT) specifier:[self specifierForID:@"CMBBadgeSizeAdjustment"]];
	[self setPreferenceValue:@(CMB_DEFAULT_USE_UNMASKED_ICONS) specifier:[self specifierForID:@"CMBUseUnmaskedIcons"]];
	[self setPreferenceValue:@(CMB_DEFAULT_SHOW_ALL_BADGES) specifier:[self specifierForID:@"CMBShowAllBadges"]];
	[self setPreferenceValue:@(CMB_DEFAULT_SWITCHER_BADGES_ENABLED) specifier:[self specifierForID:@"CMBSwitcherBadgesEnabled"]];
	[self setPreferenceValue:@(CMB_DEFAULT_PROVIDE_COLORS_FOR_COLORBANNERS) specifier:[self specifierForID:@"CMBProvideColorsForColorBanners"]];
}

@end

// vim:ft=objc
