#import "CMBCreditsListController.h"

@implementation CMBCreditsListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCredits" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
