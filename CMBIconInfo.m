#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "SpringBoard.h"
#import "CMBIconInfo.h"

@implementation CMBIconInfo

- (CMBIconInfo *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

+ (CMBIconInfo *)sharedInstance
{
	static CMBIconInfo *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBIconInfo alloc] init];
		// Do any other initialisation stuff here
	});

	return sharedInstance;
}

- (CMBIconInfo *)getIconInfo:(id)icon
{
	CMBIconInfo *iconInfo = [[CMBIconInfo alloc] init];

	iconInfo.icon = icon;

	if ([icon isKindOfClass:NSClassFromString(@"SBApplicationIcon")])
	{
		// should be same as nodeIdentifier
		iconInfo.nodeIdentifier = [icon applicationBundleID];
		iconInfo.displayName = [icon displayName];
		iconInfo.isApplication = YES;

#if 0
		LSApplicationProxy *proxy = [objc_getClass("LSApplicationProxy") applicationProxyForIdentifier:iconInfo.nodeIdentifier];

		if (proxy)
		{
			iconInfo.displayName = [proxy localizedName];
		}
#endif
	}
	else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
	{
		// [icon nodeIdentifier] -- this selector should exist, but crashes on 9.3.3 (maybe elsewhere) with error:
		// *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[SBFolderIcon copyWithZone:]: unrecognized selector sent to instance 0x........'
		//iconInfo.nodeIdentifier = [icon nodeIdentifier];

		// just looking for uniqueness so this should suffice:
		iconInfo.nodeIdentifier = [NSString stringWithFormat:@"%p", icon];
		iconInfo.displayName = [icon displayName];
		iconInfo.isApplication = NO;
	}
	else
	{
		HBLogDebug(@"getIconInfo: unhandled icon: %@", NSStringFromClass([icon class]));

		return nil;
	}

	return iconInfo;
}

- (id)realBadgeNumberOrString
{
	return [self.icon badgeNumberOrString];
}

- (id)fakeBadgeNumberOrString
{
	// have to dip into application, otherwise numeric values get converted twice (e.g. "8" becomes "1000" then "1111101000")
	if (self.isApplication)
		return [[self.icon application] badgeValue];

	return [self.icon badgeNumberOrString];
}

@end

// vim:ft=objc
