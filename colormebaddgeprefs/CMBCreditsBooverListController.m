#import "CMBCreditsBooverListController.h"

@implementation CMBCreditsBooverListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsBoover" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
