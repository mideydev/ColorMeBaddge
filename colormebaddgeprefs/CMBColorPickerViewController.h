#import <Preferences/PSViewController.h>
#import "HRColorPickerView.h"
#import "HRBrightnessSlider.h"
#import "HRColorMapView.h"

@interface CMBColorPickerViewController : UIViewController
@property (retain, nonatomic) HRColorPickerView *colorPickerView;
@property (copy) void (^ resultCallback)(UIColor *color);
- (void)showInViewController:(UIViewController *)viewController title:(NSString *)title initialColor:(UIColor *)color resultCallback:(void (^)(UIColor *))callback;
@end

// vim:ft=objc
