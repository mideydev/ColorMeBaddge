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
	[self setPreferenceValue:[@(CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE) stringValue] specifier:[self specifierForID:@"CMBFolderBadgeBackgroundType"]];
	[self setPreferenceValue:@CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR specifier:[self specifierForID:@"CMBFolderBadgeBackgroundColor"]];
	[self setPreferenceValue:[@(CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE) stringValue] specifier:[self specifierForID:@"CMBFolderBadgeForegroundType"]];
	[self setPreferenceValue:@CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR specifier:[self specifierForID:@"CMBFolderBadgeForegroundColor"]];
}

@end

// vim:ft=objc
