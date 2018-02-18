#import "CMBCreditsHRColorPickerListController.h"

@implementation CMBCreditsHRColorPickerListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsHRColorPicker" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
