#import "CMBCreditsLEColorPickerListController.h"

@implementation CMBCreditsLEColorPickerListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsLEColorPicker" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
