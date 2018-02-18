#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "SpringBoard.h"
#import "CMBPreferences.h"
#import "CMBManager.h"
#import "colormebaddgeprefs/external/HRColorPicker/UIColor+HRColorPickerHexColor.h"

@implementation CMBPreferences

static void settingsChanged(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[CMBPreferences sharedInstance] refreshSettings];
	[[CMBPreferences sharedInstance] loadSettings];
	[[CMBPreferences sharedInstance] redrawBadges];
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
	HBLogDebug(@"[logSettings] ---[ main ]---");
	HBLogDebug(@"[logSettings] tweakEnabled                     = %@",self.tweakEnabled?@"YES":@"NO");

	HBLogDebug(@"[logSettings] ---[ app badges ]---");
	HBLogDebug(@"[logSettings] appBadgeBackgroundType           = %ld",(long)self.appBadgeBackgroundType);
	HBLogDebug(@"[logSettings] appBadgeBackgroundAdjustmentType = %ld",(long)self.appBadgeBackgroundAdjustmentType);
	HBLogDebug(@"[logSettings] appBadgeBackgroundColor          = %@",self.appBadgeBackgroundColor);
	HBLogDebug(@"[logSettings] appBadgeForegroundType           = %ld",(long)self.appBadgeForegroundType);
	HBLogDebug(@"[logSettings] appBadgeForegroundAdjustmentType = %ld",(long)self.appBadgeForegroundAdjustmentType);
	HBLogDebug(@"[logSettings] appBadgeForegroundColor          = %@",self.appBadgeForegroundColor);

	HBLogDebug(@"[logSettings] ---[ folder badges ]---");
	HBLogDebug(@"[logSettings] folderBadgeBackgroundType        = %ld",(long)self.folderBadgeBackgroundType);
	HBLogDebug(@"[logSettings] folderBadgeBackgroundColor       = %@",self.folderBadgeBackgroundColor);
	HBLogDebug(@"[logSettings] folderBadgeForegroundType        = %ld",(long)self.folderBadgeForegroundType);
	HBLogDebug(@"[logSettings] folderBadgeForegroundColor       = %@",self.folderBadgeForegroundColor);

	HBLogDebug(@"[logSettings] ---[ special badges ]---");
	HBLogDebug(@"[logSettings] specialBadgesEnabled             = %@",self.specialBadgesEnabled?@"YES":@"NO");
	HBLogDebug(@"[logSettings] specialBadgesBackgroundColor     = %@",self.specialBadgesBackgroundColor);
	HBLogDebug(@"[logSettings] specialBadgesForegroundColor     = %@",self.specialBadgesForegroundColor);

	HBLogDebug(@"[logSettings] ---[ border settings ]---");
	HBLogDebug(@"[logSettings] badgeBordersEnabled              = %@",self.badgeBordersEnabled?@"YES":@"NO");
	HBLogDebug(@"[logSettings] badgeBorderType                  = %ld",(long)self.badgeBorderType);
	HBLogDebug(@"[logSettings] badgeBorderWidth                 = %0.2f",self.badgeBorderWidth);
	HBLogDebug(@"[logSettings] badgeBorderColor                 = %@",self.badgeBorderColor);

	HBLogDebug(@"[logSettings] ---[ brightness settings ]---");
	HBLogDebug(@"[logSettings] brightnessThreshold              = %ld",(long)self.brightnessThreshold);
	HBLogDebug(@"[logSettings] colorSpaceType                   = %ld",(long)self.colorSpaceType);
	HBLogDebug(@"[logSettings] badgeColorAdjustmentType         = %ld",(long)self.badgeColorAdjustmentType);

	HBLogDebug(@"[logSettings] ---[ miscellaneous settings ]---");
	HBLogDebug(@"[logSettings] useUnmaskedIcons                 = %@",self.useUnmaskedIcons?@"YES":@"NO");
	HBLogDebug(@"[logSettings] showAllBadges                    = %@",self.showAllBadges?@"YES":@"NO");
	HBLogDebug(@"[logSettings] switcherBadgesEnabled            = %@",self.switcherBadgesEnabled?@"YES":@"NO");
}

- (void)loadInitialSettings
{
	// main
	self.tweakEnabled = CMB_DEFAULT_TWEAK_ENABLED;

	// app badges
	self.appBadgeBackgroundType = CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE;
	self.appBadgeBackgroundAdjustmentType = CMB_DEFAULT_APP_BADGE_BACKGROUND_ADJUSTMENT_TYPE;
	self.appBadgeBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR];
	self.appBadgeForegroundType = CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE;
	self.appBadgeForegroundAdjustmentType = CMB_DEFAULT_APP_BADGE_FOREGROUND_ADJUSTMENT_TYPE;
	self.appBadgeForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR];

	// folder badges
	self.folderBadgeBackgroundType = CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE;
	self.folderBadgeBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR];
	self.folderBadgeForegroundType = CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE;
	self.folderBadgeForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR];

	// special badges
	self.specialBadgesEnabled = CMB_DEFAULT_SPECIAL_BADGES_ENABLED;
	self.specialBadgesBackgroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_SPECIAL_BADGE_BACKGROUND_COLOR];
	self.specialBadgesForegroundColor = [UIColor colorFromHexString:@CMB_DEFAULT_SPECIAL_BADGE_FOREGROUND_COLOR];

	// border settings
	self.badgeBordersEnabled = CMB_DEFAULT_BADGE_BORDERS_ENABLED;
	self.badgeBorderType = CMB_DEFAULT_BADGE_BORDER_TYPE;
	self.badgeBorderColor = [UIColor colorFromHexString:@CMB_DEFAULT_BADGE_BORDER_COLOR];
	self.badgeBorderWidth = CMB_DEFAULT_BADGE_BORDER_WIDTH;

	// brightness settings
	self.colorSpaceType = CMB_DEFAULT_COLOR_SPACE_TYPE;
	self.brightnessThreshold = CMB_DEFAULT_BRIGHTNESS_THRESHOLD;
	self.badgeColorAdjustmentType = CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE;

	// miscellaneous settings
	self.useUnmaskedIcons = CMB_DEFAULT_USE_UNMASKED_ICONS;
	self.showAllBadges = CMB_DEFAULT_SHOW_ALL_BADGES;
	self.switcherBadgesEnabled = CMB_DEFAULT_SWITCHER_BADGES_ENABLED;

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

		// main
		if ((pref = [settings objectForKey:@"tweakEnabled"])) self.tweakEnabled = [pref boolValue];

		// app badges
		if ((pref = [settings objectForKey:@"appBadgeBackgroundType"])) self.appBadgeBackgroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appBadgeBackgroundAdjustmentType"])) self.appBadgeBackgroundAdjustmentType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appBadgeBackgroundColor"])) self.appBadgeBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"appBadgeForegroundType"])) self.appBadgeForegroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appBadgeForegroundAdjustmentType"])) self.appBadgeForegroundAdjustmentType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appBadgeForegroundColor"])) self.appBadgeForegroundColor = [UIColor colorFromHexString:pref];

		// folder badges
		if ((pref = [settings objectForKey:@"folderBadgeBackgroundType"])) self.folderBadgeBackgroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"folderBadgeBackgroundColor"])) self.folderBadgeBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"folderBadgeForegroundType"])) self.folderBadgeForegroundType = [pref integerValue];
		if ((pref = [settings objectForKey:@"folderBadgeForegroundColor"])) self.folderBadgeForegroundColor = [UIColor colorFromHexString:pref];

		// special badges
		if ((pref = [settings objectForKey:@"specialBadgesEnabled"])) self.specialBadgesEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"specialBadgesBackgroundColor"])) self.specialBadgesBackgroundColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"specialBadgesForegroundColor"])) self.specialBadgesForegroundColor = [UIColor colorFromHexString:pref];

		// border settings
		if ((pref = [settings objectForKey:@"badgeBordersEnabled"])) self.badgeBordersEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"badgeBorderType"])) self.badgeBorderType = [pref integerValue];
		if ((pref = [settings objectForKey:@"badgeBorderColor"])) self.badgeBorderColor = [UIColor colorFromHexString:pref];
		if ((pref = [settings objectForKey:@"badgeBorderWidth"])) self.badgeBorderWidth = [pref doubleValue];

		// brightness settings
		if ((pref = [settings objectForKey:@"colorSpaceType"])) self.colorSpaceType = [pref integerValue];
		if ((pref = [settings objectForKey:@"brightnessThreshold"])) self.brightnessThreshold = [pref integerValue];
		if ((pref = [settings objectForKey:@"badgeColorAdjustmentType"])) self.badgeColorAdjustmentType = [pref integerValue];

		// miscellaneous settings
		if ((pref = [settings objectForKey:@"useUnmaskedIcons"])) self.useUnmaskedIcons = [pref boolValue];
		if ((pref = [settings objectForKey:@"showAllBadges"])) self.showAllBadges = [pref boolValue];
		if ((pref = [settings objectForKey:@"switcherBadgesEnabled"])) self.switcherBadgesEnabled = [pref boolValue];

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

-(void)redrawBadges
{
	for (SBIcon *icon in [[[objc_getClass("SBIconController") sharedInstance] model] leafIcons])
		[icon noteBadgeDidChange];
}

@end

// vim:ft=objc
