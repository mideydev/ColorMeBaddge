#import <UIKit/UIKit.h>

@interface UIColor (HRColorPickerHexColor)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (NSString *)hexString;
@end
