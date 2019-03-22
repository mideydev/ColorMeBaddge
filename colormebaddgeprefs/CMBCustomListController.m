#import "CMBCustomListController.h"

@implementation CMBCustomListController

- (id)init
{
	self = [super init];

	if (self)
	{
		_tweakBundle = [NSBundle bundleWithPath:@CMB_TWEAK_BUNDLE];
		[self loadSettings];
	}

	return self;
}

- (void)loadSettings
{
	HBLogDebug(@"loadSettings:");

	_tweakSettings = ([NSMutableDictionary dictionaryWithContentsOfFile:@CMB_PREFS_FILE] ?: [NSMutableDictionary dictionary]);

#ifdef DEBUG
	for (id key in _tweakSettings)
		HBLogDebug(@"loadSettings: key: %@  =>  value: %@", key, [_tweakSettings objectForKey:key]);
#endif
}

- (void)saveSettings
{
	HBLogDebug(@"saveSettings:");

	[_tweakSettings writeToFile:@CMB_PREFS_FILE atomically:YES];

#ifdef DEBUG
	for (id key in _tweakSettings)
		HBLogDebug(@"saveSettings: key: %@  =>  value: %@", key, [_tweakSettings objectForKey:key]);
#endif
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];

	[self loadSettings];

	[_tweakSettings setObject:value forKey:key];

	[self saveSettings];

	NSString *notification = [specifier propertyForKey:@"PostNotification"];

	HBLogDebug(@"setPreferenceValue: notification = [%@]", notification ? notification : @"");

	if (!notification || [notification isEqualToString:@""])
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(CMB_PREFS_CHANGED_NOTIFICATION), NULL, NULL, TRUE);
	else
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)notification, NULL, NULL, TRUE);
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];

	HBLogDebug(@"readPreferenceValue: key = %@", key);

	id defaultValue = [specifier propertyForKey:@"default"];
	HBLogDebug(@"readPreferenceValue: defaultValue = %@", defaultValue);

	id plistValue = [_tweakSettings objectForKey:key];
	HBLogDebug(@"readPreferenceValue: plistValue = %@", plistValue);

	if (!plistValue)
	{
		[_tweakSettings setObject:defaultValue forKey:key];
		[self saveSettings];
		plistValue = defaultValue;
	}

	return plistValue;
}

- (void)didTapColorPreviewAtIndexPath:(NSIndexPath *)indexPath
{
	HBLogDebug(@"didTapColorPreviewAtIndexPath: %@", indexPath);

	PSSpecifier *specifier = [self specifierAtIndex:[self indexForRow:indexPath.row inGroup:indexPath.section]];

	NSString *colorString = [self readPreferenceValue:specifier];
	UIColor *color = [UIColor colorFromHexString:colorString];

	CMBColorPickerViewController *colorPicker = [[CMBColorPickerViewController alloc] init];

	[colorPicker showInViewController:self title:specifier.name initialColor:color resultCallback:^(UIColor *newColor)
	{
		[self setPreferenceValue:[newColor hexString] specifier:specifier];

		[self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	PSSpecifier *specifier = [self specifierAtIndex:[self indexForRow:indexPath.row inGroup:indexPath.section]];

	if ([cell isKindOfClass:[CMBColorPickerCell class]])
	{
		CMBColorPickerCell *colorPickerCell = (CMBColorPickerCell *)cell;

		NSString *colorString = [self readPreferenceValue:specifier];
		UIColor *color = [UIColor colorFromHexString:colorString];

		[colorPickerCell setDelegate:self];
		[colorPickerCell setIndexPath:indexPath];
		[colorPickerCell setColor:color];
		[colorPickerCell updateColorPreview];
	}

	return cell;
}

- (void)resetSettings
{
	HBLogDebug(@"resetSettings: warning: unoverrided method");
}

- (void)reset
{
	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:CMBLocalizedStringForKey(@"RESET_CONFIRMATION_TITLE")
								message:CMBLocalizedStringForKey(@"RESET_CONFIRMATION_MESSAGE")
								preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *yesButton = [UIAlertAction
								actionWithTitle:CMBLocalizedStringForKey(@"CONFIRMATION_YES")
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									[self resetSettings];
									[self reloadSpecifiers];
								}];

	UIAlertAction *noButton = [UIAlertAction
								actionWithTitle:CMBLocalizedStringForKey(@"CONFIRMATION_NO")
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									//Do nothing
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}

@end

// vim:ft=objc
