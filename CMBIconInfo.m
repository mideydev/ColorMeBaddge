#import <Foundation/Foundation.h>
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
		iconInfo.nodeIdentifier = [icon applicationBundleID];
//		iconInfo.image = [icon getIconImage:1];
//		iconInfo.unmaskedImage = [icon getUnmaskedIconImage:1];
		iconInfo.isApplication = YES;
//		iconInfo.isFolder = NO;

	}
	else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
	{
		iconInfo.nodeIdentifier = [[icon folder] displayName];
//		iconInfo.image = [icon _miniIconGridForPage:0];
//		iconInfo.unmaskedImage = nil;
		iconInfo.isApplication = NO;
//		iconInfo.isFolder = YES;
	}
	else
	{
//		HBLogDebug(@"getIconInfo: unhandled icon: %@",NSStringFromClass([icon class]));

		return nil;
	}

	return iconInfo;
}

@end

// vim:ft=objc
