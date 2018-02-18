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
- (NSInteger)getBadgeValueType:(id)badgeNumberOrString;
- (void)refreshBadges:(NSString *)applicationBundleID;
- (void)refreshBadgesForApplication:(NSString *)applicationBundleID;
- (void)refreshBadgesForAllApplications;
@end

// vim:ft=objc
