//#import "SpringBoard.h"
#import "CMBColorInfo.h"

#define NORMALIZED_BRIGHTNESS_SCALE	1000.0

#define SHADE_PERCENTAGE			(25.0 / 100.0)
#define TINT_PERCENTAGE				(25.0 / 100.0)

@interface CMBSexerUpper : NSObject
+ (instancetype)sharedInstance;
- (UIColor *)getForegroundColorByBrightnessThreshold:(UIColor *)backgroundColor;
- (UIColor *)adjustBackgroundColorByPreference:(UIColor *)color;
- (UIColor *)adjustBorderColorByPreference:(UIColor *)color;
- (UIColor *)adjustAppBadgeBackgroundColorByPreference:(UIColor *)color;
- (UIColor *)adjustAppBadgeForegroundColorByPreference:(UIColor *)color;
- (CMBColorInfo *)getColorsUsingLEColorPicker:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingCCColorCube:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingBooverAlgorithm:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingColorBadges:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingChameleon:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingRandom;
- (int)DRGBFromUIColor:(UIColor *)color;
@end

// vim:ft=objc
