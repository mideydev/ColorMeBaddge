#import "SpringBoard.h"
#import "CMBColorInfo.h"

#define NORMALIZED_BRIGHTNESS_SCALE 1000.0

@interface CMBSexerUpper : NSObject
+ (CMBSexerUpper *)sharedInstance;
- (UIColor *)getForegroundColorByBrightnessThreshold:(UIColor *)backgroundColor;
- (UIColor *)adjustBackgroundColorByPreference:(UIColor *)color;
- (UIColor *)adjustBorderColorByPreference:(UIColor *)color;
- (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color;
- (CMBColorInfo *)getColorsUsingLEColorPicker:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingCCColorCube:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingBooverAlgorithm:(UIImage *)image;
- (CMBColorInfo *)getColorsUsingColorBadges:(UIImage *)image;
@end

// vim:ft=objc
