#import "SpringBoard.h"
#import "CMBManager.h"

static void respring(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

static void refreshBadgesForAppcon(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	NSString *applicationBundleID = (__bridge NSString *)object;

	[[CMBManager sharedInstance] refreshBadges:applicationBundleID];
}

%ctor
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBadges.dylib",RTLD_LAZY);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		respring,
		CFSTR("org.midey.colormebaddge/respringRequested"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		NULL,
		refreshBadgesForAppcon,
		CFSTR("com.merdok.appcon.iconimagechanged"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}

// vim:ft=objc
