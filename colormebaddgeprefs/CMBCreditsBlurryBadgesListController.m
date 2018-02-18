#import "CMBCreditsBlurryBadgesListController.h"

@implementation CMBCreditsBlurryBadgesListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgeCreditsBlurryBadges" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
