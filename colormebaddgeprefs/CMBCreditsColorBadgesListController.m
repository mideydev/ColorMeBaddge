#import "CMBCreditsColorBadgesListController.h"

@implementation CMBCreditsColorBadgesListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsColorBadges" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
