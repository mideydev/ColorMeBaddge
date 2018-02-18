#import <Preferences/PSViewController.h>
#import "external/HRColorPicker/HRColorPickerView.h"
#import "external/HRColorPicker/HRBrightnessSlider.h"
#import "external/HRColorPicker/HRColorMapView.h"

@interface CMBColorPickerViewController : UIViewController
@property (retain, nonatomic) HRColorPickerView *colorPickerView;
@property (copy) void (^ resultCallback)(UIColor *color);
- (void)showInViewController:(UIViewController *)viewController title:(NSString *)title initialColor:(UIColor *)color resultCallback:(void (^)(UIColor *))callback;
@end

// vim:ft=objc
