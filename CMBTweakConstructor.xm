#import "SpringBoard.h"

static void respring(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
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
}

// vim:ft=objc
