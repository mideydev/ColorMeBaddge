#import "CMBShapeListController.h"

@implementation CMBShapeListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeShapePrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_SIZE_ADJUSTMENT) specifier:[self specifierForID:@"CMBBadgeSizeAdjustment"]];
	[self setPreferenceValue:@(CMB_DEFAULT_BADGE_CORNER_ROUNDNESS_SCALE) specifier:[self specifierForID:@"CMBBadgeCornerRoundnessScale"]];
}

@end

// vim:ft=objc
