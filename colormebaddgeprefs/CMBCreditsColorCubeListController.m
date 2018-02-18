#import "CMBCreditsColorCubeListController.h"

@implementation CMBCreditsColorCubeListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsColorCube" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
