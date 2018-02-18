#import "CMBColorInfo.h"
// springboard stuff

@interface FBSystemService : NSObject
- (id)sharedInstance;
- (void)exitAndRelaunch:(bool)arg1;
@end

@interface SBIcon : NSObject
- (id)getIconImage:(int)arg1;
- (id)nodeIdentifier;
@property(retain, nonatomic) SBIcon *icon;
@end

@interface SBLeafIcon : SBIcon
- (id)applicationBundleID;
@end

@interface SBIconListModel : NSObject
- (id)icons;
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

@interface SBFolderIconView : SBIcon
- (id)folder;
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
@end

@interface SBIconAccessoryImage : UIImage
- (id)initWithImage:(id)arg1;
@end

@interface SBApplicationPlaceholder : NSObject
@property(copy, nonatomic) NSString *applicationBundleID;
@end

@interface SBIconBadgeView : UIView
{
	SBIconAccessoryImage *_backgroundImage;
	SBDarkeningImageView *_backgroundView;
	SBIconAccessoryImage *_textImage;
	SBDarkeningImageView *_textView;
}
// CMB:
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon prepareForCrossfade:(BOOL)prepareForCrossfade;
- (void)setBadgeColors:(CMBColorInfo *)badgeColors;
- (void)setBadgeBackgroundColor:(CMBColorInfo *)badgeColors;
- (void)setBadgeForegroundColor:(CMBColorInfo *)badgeColors;
@end

// vim:ft=objc
