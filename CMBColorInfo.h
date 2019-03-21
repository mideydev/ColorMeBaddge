// full rgb white/black
#define realWhiteColor							[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define realBlackColor							[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]

// fallback colors
#define stockRedColor							[UIColor colorWithRed:(255.0f/255.0f) green:(59.0f/255.0f) blue:(48.0f/255.0f) alpha:1.0f]

#define fallbackAppBadgeBackgroundColor			stockRedColor
#define fallbackAppBadgeForegroundColor			realWhiteColor

#define fallbackFolderBadgeBackgroundColor		stockRedColor
#define fallbackFolderBadgeForegroundColor		realWhiteColor

#define fallbackSpecialBadgeBackgroundColor		[UIColor yellowColor]
#define fallbackSpecialBadgeForegroundColor		[UIColor redColor]

#define fallbackDisabledBadgeBackgroundColor	stockRedColor
#define fallbackDisabledBadgeForegroundColor	realWhiteColor

#define fallbackUnknownBadgeBackgroundColor		stockRedColor
#define fallbackUnknownBadgeForegroundColor		realWhiteColor

@interface CMBColorInfo : NSObject
@property(nonatomic,strong)	UIColor *backgroundColor;
@property(nonatomic,strong)	UIColor *foregroundColor;
@property(nonatomic,strong)	UIColor *borderColor;
@property(nonatomic)		CFAbsoluteTime now;

+ (instancetype)sharedInstance;
- (CMBColorInfo *)colorInfoWithBackgroundColor:(UIColor *)backgroundColor andForegroundColor:(UIColor *)foregroundColor;
@end

// vim:ft=objc
