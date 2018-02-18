#import "CMBCreditsColoursListController.h"

@implementation CMBCreditsColoursListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsColours" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
