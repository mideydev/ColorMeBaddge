// full rgb white/black
#define realWhiteColor							[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
#define realBlackColor							[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]

// fallback colors
#define fallbackAppBadgeBackgroundColor			[UIColor redColor]
#define fallbackAppBadgeForegroundColor			realWhiteColor

#define fallbackFolderBadgeBackgroundColor		[UIColor redColor]
#define fallbackFolderBadgeForegroundColor		realWhiteColor

#define fallbackSpecialBadgeBackgroundColor		[UIColor yellowColor]
#define fallbackSpecialBadgeForegroundColor		[UIColor redColor]

#define fallbackDisabledBadgeBackgroundColor	[UIColor redColor]
#define fallbackDisabledBadgeForegroundColor	realWhiteColor

#define fallbackUnknownBadgeBackgroundColor		[UIColor redColor]
#define fallbackUnknownBadgeForegroundColor		realWhiteColor

@interface CMBColorInfo : NSObject
@property(nonatomic,strong)	UIColor *backgroundColor;
@property(nonatomic,strong)	UIColor *foregroundColor;
@property(nonatomic)		CFAbsoluteTime now;

+ (CMBColorInfo *)sharedInstance;
- (CMBColorInfo *)colorInfoWithBackgroundColor:(UIColor *)backgroundColor andForegroundColor:(UIColor *)foregroundColor;
@end

// vim:ft=objc
