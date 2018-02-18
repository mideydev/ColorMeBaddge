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
#define CMB_DEFAULT_BADGE_BORDERS_ENABLED			NO
#define CMB_DEFAULT_BADGE_BORDER_WIDTH				1.0
#define CMB_DEFAULT_SWITCHER_BADGES_ENABLED			NO

// preference defaults (types)
#define CMB_DEFAULT_APP_BADGE_BACKGROUND_TYPE		kABB_CCColorCube
#define CMB_DEFAULT_APP_BADGE_FOREGROUND_TYPE		kABF_ByBrightness
#define CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_TYPE	kFBB_RandomBadge
#define CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_TYPE	kFBF_ByBadgeElseBrightness
#define CMB_DEFAULT_COLOR_SPACE_TYPE				kColorSpaceCIELAB
#define CMB_DEFAULT_BADGE_COLOR_ADJUSTMENT_TYPE		kNoAdjustment
#define CMB_DEFAULT_BADGE_BORDER_TYPE				kBB_ByBadgeForegroundColor

// preference defaults (colors)
#define CMB_DEFAULT_APP_BADGE_BACKGROUND_COLOR		CMB_HEXCOLOR_RED
#define CMB_DEFAULT_APP_BADGE_FOREGROUND_COLOR		CMB_HEXCOLOR_WHITE
#define CMB_DEFAULT_FOLDER_BADGE_BACKGROUND_COLOR	CMB_HEXCOLOR_OCEAN
#define CMB_DEFAULT_FOLDER_BADGE_FOREGROUND_COLOR	CMB_HEXCOLOR_WHITE
#define CMB_DEFAULT_SPECIAL_BADGE_BACKGROUND_COLOR	CMB_HEXCOLOR_YELLOW
#define CMB_DEFAULT_SPECIAL_BADGE_FOREGROUND_COLOR	CMB_HEXCOLOR_RED
#define CMB_DEFAULT_BADGE_BORDER_COLOR				CMB_HEXCOLOR_WHITE

typedef NS_ENUM(NSUInteger,AppBadgeBackgroundType)
{
	kABB_FixedColor = 0,
	kABB_CCColorCube,
	kABB_LEColorPicker,
	kABB_Boover,
	kABB_ColorBadges
};

typedef NS_ENUM(NSUInteger,AppBadgeForegroundType)
{
	kABF_FixedColor = 0,
	kABF_ByBrightness,
	kABF_ByAlgorithmElseFixedColor,
	kABF_ByAlgorithmElseBrightness
};

typedef NS_ENUM(NSUInteger,FolderBadgeBackgroundType)
{
	kFBB_FixedColor = 0,
	kFBB_LowestBadge,
	kFBB_HighestBadge,
	kFBB_FirstBadge,
	kFBB_LastBadge,
	kFBB_RandomBadge,
	kFBB_AverageColor,
	kFBB_WeightedAverageColor,
	kFBB_FolderMinigrid
};

typedef NS_ENUM(NSUInteger,FolderBadgeForegroundType)
{
	kFBF_FixedColor = 0,
	kFBF_ByBrightness,
	kFBF_ByBadgeElseFixedColor,
	kFBF_ByBadgeElseBrightness
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

typedef NS_ENUM(NSUInteger,BadgeBorderType)
{
	kBB_FixedColor = 0,
	kBB_ByBrightness,
	kBB_ByBadgeForegroundColor,
	kBB_ByShadedBadgeBackgroundColor,
	kBB_ByTintedBadgeBackgroundColor
};

@interface CMBPreferences : NSObject
{
	NSMutableDictionary *settings;
}
@property(nonatomic)		BOOL tweakEnabled;
@property(nonatomic)		BOOL specialBadgesEnabled;
@property(nonatomic)		BOOL useUnmaskedIcons;
@property(nonatomic)		BOOL showAllBadges;
@property(nonatomic)		BOOL badgeBordersEnabled;
@property(nonatomic)		BOOL switcherBadgesEnabled;
@property(nonatomic)		NSInteger appBadgeBackgroundType;
@property(nonatomic)		NSInteger appBadgeForegroundType;
@property(nonatomic)		NSInteger folderBadgeBackgroundType;
@property(nonatomic)		NSInteger folderBadgeForegroundType;
@property(nonatomic)		NSInteger colorSpaceType;
@property(nonatomic)		NSInteger brightnessThreshold;
@property(nonatomic)		NSInteger badgeColorAdjustmentType;
@property(nonatomic)		NSInteger badgeBorderType;
@property(nonatomic)		CGFloat badgeBorderWidth;
@property(nonatomic,strong)	UIColor *appBadgeBackgroundColor;
@property(nonatomic,strong)	UIColor *appBadgeForegroundColor;
@property(nonatomic,strong)	UIColor *folderBadgeBackgroundColor;
@property(nonatomic,strong)	UIColor *folderBadgeForegroundColor;
@property(nonatomic,strong)	UIColor *specialBadgesBackgroundColor;
@property(nonatomic,strong)	UIColor *specialBadgesForegroundColor;
@property(nonatomic,strong)	UIColor *badgeBorderColor;

+ (CMBPreferences *)sharedInstance;
@end

// vim:ft=objc
