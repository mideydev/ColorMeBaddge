#import "CMBColorInfo.h"

#define SYSTEM_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// springboard stuff

@interface FBSystemService : NSObject
- (id)sharedInstance;
- (void)exitAndRelaunch:(bool)arg1;
@end

@interface SBIcon : NSObject
- (id)getIconImage:(int)arg1;
- (id)nodeIdentifier;
- (id)badgeNumberOrString;
- (void)noteBadgeDidChange;
- (void)setBadge:(id)arg1;
@property(retain, nonatomic) SBIcon *icon;
@end

@interface SBLeafIcon : SBIcon
- (id)applicationBundleID;
@end

@interface SBIconListModel : NSObject
- (id)icons;
@end

@interface SBIconModel : NSObject
- (id)applicationIconForBundleIdentifier:(id)arg1;
- (id)expectedIconForDisplayIdentifier:(id)arg1;
- (id)leafIcons;
@end

@interface SBFolder : NSObject
@property(readonly, copy, nonatomic) NSArray *lists;
@end

@interface SBFolderIcon : SBIcon
- (id)folder;
//- (id)orderedIcons; // not available in 8.4
//- (id)visibleIcons;
- (id)_miniIconGridForPage:(long long)arg1;
@end

@interface SBApplicationIcon : SBLeafIcon
- (id)application;
- (id)getUnmaskedIconImage:(int)arg1;
- (id)badgeNumberOrString;
@end

@interface SBDarkeningImageView : UIImageView
- (void)setImage:(id)arg1;
@end

@interface SBIconController : UIViewController
+ (id)sharedInstance;
- (_Bool)iconAllowsBadging:(id)arg1;
- (id)model;
@end

@interface SBIconAccessoryImage : UIImage
- (id)initWithImage:(id)arg1;
@end

@interface SBApplicationPlaceholder : NSObject
@property(copy, nonatomic) NSString *applicationBundleID;
@end

@interface SBIconBadgeView : UIView
+ (CGSize)badgeSize;
// CMB:
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon prepareForCrossfade:(BOOL)prepareForCrossfade;
- (void)setBadgeColors:(CMBColorInfo *)badgeColors;
- (void)setBadgeBackgroundColor:(CMBColorInfo *)badgeColors;
- (void)setBadgeForegroundColor:(CMBColorInfo *)badgeColors;
- (NSString *)getCrossfadeColorKey;
@end

@interface SBDisplayItem : NSObject
@property(readonly, copy, nonatomic) NSString *displayIdentifier;
@end

@interface SBDeckSwitcherIconImageContainerView : UIView
@property(retain, nonatomic) UIImageView *imageView;
@property(retain, nonatomic) SBIcon *icon;
@property(readonly, nonatomic) SBDisplayItem *displayItem;
// CMB:
- (void)createSwitcherIconBadge;
@end

@interface SBFluidSwitcherIconImageContainerView : UIView
@property(retain, nonatomic) UIImageView *imageView;
@property(retain, nonatomic) SBIcon *icon;
@property(readonly, nonatomic) SBDisplayItem *displayItem;
// CMB:
- (void)createSwitcherIconBadge;
@end

// vim:ft=objc
