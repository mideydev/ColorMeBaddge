#import "CMBCreditsCouriaListController.h"

@implementation CMBCreditsCouriaListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsCouria" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
