#import "CMBFoldersListController.h"

@implementation CMBFoldersListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeFoldersPrefs" target:self];
	}

	return _specifiers;
}

- (void)resetSettings
{
	PSSpecifier *specifier;

	specifier = [self specifierForID:@"CMBFolderBadgeBackgroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBFolderBadgeBackgroundType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE) stringValue] specifier:specifier];

	specifier = [self specifierForID:@"CMBFolderBadgeForegroundColor"];
	[self setPreferenceValue:@CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR specifier:specifier];

	specifier = [self specifierForID:@"CMBFolderBadgeForegroundType"];
	[self setPreferenceValue:[@(CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE) stringValue] specifier:specifier];
}

@end

// vim:ft=objc
