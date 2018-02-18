#import "CMBCreditsChameleonListController.h"

@implementation CMBCreditsChameleonListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsChameleon" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
