#import <Foundation/Foundation.h>
#import "CMBColorInfo.h"

@implementation CMBColorInfo

- (CMBColorInfo *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/*
- (void)dealloc
{
	[super dealloc];
}
*/

+ (CMBColorInfo *)sharedInstance
{
	static CMBColorInfo *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBColorInfo alloc] init];
		// Do any other initialisation stuff here
	});

	return sharedInstance;
}

- (CMBColorInfo *)colorInfoWithBackgroundColor:(UIColor *)backgroundColor andForegroundColor:(UIColor *)foregroundColor
{
	CMBColorInfo *badgeColors = [[CMBColorInfo alloc] init];

	badgeColors.backgroundColor = backgroundColor;
	badgeColors.foregroundColor = foregroundColor;
	badgeColors.borderColor = nil;

	return badgeColors;
}

@end

// vim:ft=objc
