// full rgb white/black
#define REAL_WHITE_COLOR	[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define REAL_BLACK_COLOR	[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]

// default stock colors (background color will get updated using color extracted from stock badge)
// some or all iOS versions prior to 12:
#define STOCK_BADGE_BACKGROUND_COLOR	[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]
// iOS 12:
//#define STOCK_BADGE_BACKGROUND_COLOR	[UIColor colorWithRed:(255.0f/255.0f) green:(59.0f/255.0f) blue:(48.0f/255.0f) alpha:1.0f]
#define STOCK_BADGE_FOREGROUND_COLOR	REAL_WHITE_COLOR

// non-stock fallback colors
#define FALLBACK_SPECIAL_BADGES_BACKGROUND_COLOR	[UIColor yellowColor]
#define FALLBACK_SPECIAL_BADGES_FOREGROUND_COLOR	[UIColor redColor]

@interface CMBColorInfo : NSObject
@property(nonatomic,strong)	UIColor *stockBackgroundColor;
@property(nonatomic,strong)	UIColor *stockForegroundColor;
@property(nonatomic,strong)	UIColor *backgroundColor;
@property(nonatomic,strong)	UIColor *foregroundColor;
@property(nonatomic,strong)	UIColor *borderColor;
@property(nonatomic)		CFAbsoluteTime now;

+ (instancetype)sharedInstance;
- (CMBColorInfo *)colorInfoWithBackgroundColor:(UIColor *)backgroundColor andForegroundColor:(UIColor *)foregroundColor;
- (CMBColorInfo *)colorInfoWithStockColors;
@end

// vim:ft=objc
