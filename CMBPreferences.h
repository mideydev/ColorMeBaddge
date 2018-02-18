// preference definitions
#define CMB_BUNDLE_ID								"org.midey.colormebaddge"
#define CMB_PREFS_DIRECTORY							"/var/mobile/Library/Preferences"
#define CMB_PREFS_FILE								CMB_PREFS_DIRECTORY "/" CMB_BUNDLE_ID ".plist"
#define CMB_PREFS_CHANGED_NOTIFICATION				"org.midey.colormebaddge/settingsChanged"

// localization definitions
#define CMB_TWEAK_BUNDLE							"/Library/Application Support/ColorMeBaddge.bundle"

// color definitions
#define CMB_HEXCOLOR_RED							"#FF0000"
#define CMB_HEXCOLOR_WHITE							"#FFFFFF"
#define CMB_HEXCOLOR_YELLOW							"#FFFF00"
#define CMB_HEXCOLOR_OCEAN							"#004A88"

// preference defaults
#define CMB_DEFAULT_TWEAK_ENABLED					YES
#define CMB_DEFAULT_SPECIAL_BADGES_ENABLED			YES
#define CMB_DEFAULT_USE_UNMASKED_ICONS				NO
#define CMB_DEFAULT_BRIGHTNESS_THRESHOLD			730
#define CMB_DEFAULT_SHOW_ALL_BADGES					NO

// preference defaults (types)
#define CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE		kABBCCColorCube
#define CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE		kABFBrightness
#define CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE	kFBBRandomBadge
#define CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE	kFBFBadgeElseBrightness
#define CMB_DEFAULT_COLOR_SPACE_TYPE				kColorSpaceCIELAB
#define CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE		kNoAdjustment

// preference defaults (colors)
#define CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR		CMB_HEXCOLOR_RED
#define CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR		CMB_HEXCOLOR_WHITE
#define CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR	CMB_HEXCOLOR_OCEAN
#define CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR	CMB_HEXCOLOR_WHITE
#define CMB_DEFAULT_SPECIAL_BADGE_BACKGROUND_COLOR	CMB_HEXCOLOR_YELLOW
#define CMB_DEFAULT_SPECIAL_BADGE_FOREGROUND_COLOR	CMB_HEXCOLOR_RED

typedef NS_ENUM(NSUInteger,AppBadgeBackgroundType)
{
	kABBFixedColor = 0,
	kABBCCColorCube,
	kABBLEColorPicker,
	kABBBoover,
	kABBColorBadges
};

typedef NS_ENUM(NSUInteger,AppBadgeForegroundType)
{
	kABFFixedColor = 0,
	kABFBrightness,
	kABFAlgorithmElseFixedColor,
	kABFAlgorithmElseBrightness
};

typedef NS_ENUM(NSUInteger,FolderBadgeBackgroundType)
{
	kFBBFixedColor = 0,
	kFBBLowestBadge,
	kFBBHighestBadge,
	kFBBFirstBadge,
	kFBBLastBadge,
	kFBBRandomBadge,
	kFBBAverageColor,
	kFBBWeightedAverageColor,
	kFBBFolderMinigrid
};

typedef NS_ENUM(NSUInteger,FolderBadgeForegroundType)
{
	kFBFFixedColor = 0,
	kFBFBrightness,
	kFBFBadgeElseFixedColor,
	kFBFBadgeElseBrightness
};

typedef NS_ENUM(NSUInteger,ColorSpaceType)
{
	kColorSpaceRGB = 0,
	kColorSpaceCIELAB
};

typedef NS_ENUM(NSUInteger,BadgeColorAdjustmentType)
{
	kNoAdjustment = 0,
	kShadeForWhiteText,
	kTintForBlackText
};

@interface CMBPreferences : NSObject
{
	NSMutableDictionary *settings;
}
@property(nonatomic)		BOOL tweakEnabled;
@property(nonatomic)		BOOL specialBadgesEnabled;
@property(nonatomic)		BOOL useUnmaskedIcons;
@property(nonatomic)		BOOL showAllBadges;
@property(nonatomic)		NSInteger appBadgeBackgroundType;
@property(nonatomic)		NSInteger appBadgeForegroundType;
@property(nonatomic)		NSInteger folderBadgeBackgroundType;
@property(nonatomic)		NSInteger folderBadgeForegroundType;
@property(nonatomic)		NSInteger colorSpaceType;
@property(nonatomic)		NSInteger brightnessThreshold;
@property(nonatomic)		NSInteger badgeColorAdjustmentType;
@property(nonatomic,strong)	UIColor *appBadgeBackgroundColor;
@property(nonatomic,strong)	UIColor *appBadgeForegroundColor;
@property(nonatomic,strong)	UIColor *folderBadgeBackgroundColor;
@property(nonatomic,strong)	UIColor *folderBadgeForegroundColor;
@property(nonatomic,strong)	UIColor *specialBadgesBackgroundColor;
@property(nonatomic,strong)	UIColor *specialBadgesForegroundColor;

+ (CMBPreferences *)sharedInstance;
@end

// vim:ft=objc
