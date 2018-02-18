//#import "SpringBoard.h"
#import "CMBColorInfo.h"
#import "CMBIconInfo.h"

typedef NS_ENUM(NSUInteger,BadgeValueType)
{
	kEmptyBadge = 0,
	kNumericBadge,
	kSpecialBadge
};

@interface CMBManager : NSObject
{
	NSMutableDictionary *cachedAppBadgeColors;
	NSMutableDictionary *cachedRandomFolderBadgeColors;
}
+ (CMBManager *)sharedInstance;
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon;
- (void)clearCachedColors;
- (void)clearCachedColorsForApplication:(NSString *)applicationBundleID;
- (NSInteger)getBadgeValueType:(id)badgeNumberOrString;
@end

// vim:ft=objc
