#import "CMBColorPickerViewController.h"
#import <objc/runtime.h>

@implementation CMBColorPickerViewController

- (HRColorPickerView *)colorPickerView
{
	if (_colorPickerView == nil)
	{
		_colorPickerView = [[HRColorPickerView alloc] init];
		_colorPickerView.colorMapView.saturationUpperLimit = @(1);
		_colorPickerView.brightnessSlider.brightnessLowerLimit = @(0);
	}

	return _colorPickerView;
}

- (void)loadView
{
	self.view = self.colorPickerView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationController.navigationBar.translucent = NO;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

- (void)showInViewController:(UIViewController *)viewController title:(NSString *)title initialColor:(UIColor *)color resultCallback:(void (^)(UIColor *))callback
{
	self.title = title;
	self.colorPickerView.color = color;
	self.resultCallback = callback;

	[viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:self] animated:YES completion:NULL];
}

- (void)cancelAction:(UIBarButtonItem *)buttonItem
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneAction:(UIBarButtonItem *)buttonItem
{
	if (self.resultCallback)
		self.resultCallback(self.colorPickerView.color);

	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end

// vim:ft=objc
