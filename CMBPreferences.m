#import <Foundation/Foundation.h>
#import "CMBPreferences.h"
#import "CMBManager.h"
#import "UIColor+HRColorPickerHexColor.h"

@implementation CMBPreferences

static void settingsChanged(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[CMBPreferences sharedInstance] refreshSettings];
	[[CMBPreferences sharedInstance] loadSettings];
}

- (CMBPreferences *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/*
- (void)dealloc
{
	if (settings)
		[settings release];

	[super dealloc];
}
*/

+ (CMBPreferences *)sharedInstance
{
	static CMBPreferences *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBPreferences alloc] init];
		// Do any other initialisation stuff here

		[sharedInstance loadInitialSettings];

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			settingsChanged,
			CFSTR(CMB_PREFS_CHANGED_NOTIFICATION),
			NULL,
			CFNotificationSuspensionBehaviorCoalesce
		);
	});

	return sharedInstance;
}

- (void)logSettings
{
	HBLogDebug(@"[logSettings] ------------------------------------");
	HBLogDebug(@"[logSettings] self.tweakEnabled               = %@",self.tweakEnabled?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.appBadgeBackgroundType     = %ld",(long)self.appBadgeBackgroundType);
	HBLogDebug(@"[logSettings] self.appBadgeForegroundType     = %ld",(long)self.appBadgeForegroundType);
	HBLogDebug(@"[logSettings] self.folderBadgeBackgroundType  = %ld",(long)self.folderBadgeBackgroundType);
	HBLogDebug(@"[logSettings] self.folderBadgeForegroundType  = %ld",(long)self.folderBadgeForegroundType);
	HBLogDebug(@"[logSettings] self.specialBadgesEnabled       = %@",self.specialBadgesEnabled?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.brightnessThreshold        = %ld",(long)self.brightnessThreshold);
	HBLogDebug(@"[logSettings] self.colorSpaceType             = %ld",(long)self.colorSpaceType);
	HBLogDebug(@"[logSettings] self.useUnmaskedIcons           = %@",self.useUnmaskedIcons?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.showAllBadges              = %@",self.showAllBadges?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.badgeColorAdjustmentType   = %ld",(long)self.badgeColorAdjustmentType);

	HBLogDebug(@"[logSettings] --------------------------------------");
	HBLogDebug(@"[logSettings] self.appBadgeBackgroundColor      = %@",self.appBadgeBackgroundColor);
	HBLogDebug(@"[logSettings] self.appBadgeForegroundColor      = %@",self.appBadgeForegroundColor);
	HBLogDebug(@"[logSettings] self.folderBadgeBackgroundColor   = %@",self.folderBadgeBackgroundColor);
	HBLogDebug(@"[logSettings] self.folderBadgeForegroundColor   = %@",self.folderBadgeForegroundColor);
	HBLogDebug(@"[logSettings] self.specialBadgesBackgroundColor = %@",self.specialBadgesBackgroundColor);
	HBLogDebug(@"[logSettings] self.specialBadgesForegroundColor = %@",self.specialBadgesForegroundColor);
}

- (void)loadInitialSettings
{
	self.tweakEnabled = CMB_DEFAULT_TWEAK_ENABLED;
	self.appBadgeBackgroundType = CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE;
	self.appBadgeForegroundType = CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE;
	self.folderBadgeBackgroundType = CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE;
	self.folderBadgeForegroundType = CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE;
	self.specialBadgesEnabled = CMB_DEFAULT_SPECIAL_BADGES_ENABLED;
	self.brightnessThreshold = CMB_DEFAULT_BRIGHTNESS_THRESHOLD;
	self.colorSpaceType = CMB_DEFAULT_COLOR_SPACE_TYPE;
	self.useUnmaskedIcons = CMB_DEFAULT_USE_UNMASKED_ICONS;
	self.showAllBadges = CMB_DEFAULT_SHOW_ALL_BADGES;
	self.badgeColorAdjustmentType = CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE;

	self.appBadgeBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR];
	self.appBadgeForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR];
	self.folderBadgeBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR];
	self.folderBadgeForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR];
	self.specialBadgesBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_SPECIAL_BADGE_BACKGROUND_COLOR];
	self.specialBadgesForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_SPECIAL_BADGE_FOREGROUND_COLOR];

	[self logSettings];

	[self refreshSettings];
	[self loadSettings];

	[self logSettings];
}

- (void)loadSettings
{
	if (settings)
	{
		id pref;

		if ((pref = [settings objectForKey:@"tweakEnabled"])) self.tweakEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"appBadgeBackgroundType"])) self.appBadgeBackgroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appBadgeForegroundType"])) self.appBadgeForegroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"folderBadgeBackgroundType"])) self.folderBadgeBackgroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"folderBadgeForegroundType"])) self.folderBadgeForegroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"specialBadgesEnabled"])) self.specialBadgesEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"brightnessThreshold"])) self.brightnessThreshold = [pref integerValue];
		if ((pref = [settings objectForKey:@"colorSpaceType"])) self.colorSpaceType = [pref integerValue];
		if ((pref = [settings objectForKey:@"useUnmaskedIcons"])) self.useUnmaskedIcons = [pref boolValue];
		if ((pref = [settings objectForKey:@"showAllBadges"])) self.showAllBadges = [pref boolValue];
		if ((pref = [settings objectForKey:@"badgeColorAdjustmentType"])) self.badgeColorAdjustmentType = [pref integerValue];

		if ((pref = [settings objectForKey:@"appBadgeBackgroundColor"])) self.appBadgeBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"appBadgeForegroundColor"])) self.appBadgeForegroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"folderBadgeBackgroundColor"])) self.folderBadgeBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"folderBadgeForegroundColor"])) self.folderBadgeForegroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"specialBadgesBackgroundColor"])) self.specialBadgesBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"specialBadgesForegroundColor"])) self.specialBadgesForegroundColor = [UIColor colorFromHexString:pref];

		[self logSettings];

		[[CMBManager sharedInstance] clearCachedColors];
	}
}

- (void)refreshSettings
{
/*
	if (settings)
	{
		[settings release];
		settings = nil;
	}
*/

	settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@CMB_PREFS_FILE];
}

@end

// vim:ft=objc
