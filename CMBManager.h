#import "SpringBoard.h"
#import "CMBColorInfo.h"
#import "CMBIconInfo.h"

@interface CMBManager : NSObject
{
	NSMutableDictionary *cachedAppBadgeColors;
	NSMutableDictionary *cachedRandomFolderBadgeColors;
}
+ (CMBManager *)sharedInstance;
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon;
- (void)clearCachedColors;
- (void)clearCachedColorsForApplication:(NSString *)applicationBundleID;
@end

// vim:ft=objc
