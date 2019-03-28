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

+ (CMBColorInfo *)sharedInstance
{
	static CMBColorInfo *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBColorInfo alloc] init];
		// Do any other initialisation stuff here
		sharedInstance.stockBackgroundColor = STOCK_BADGE_BACKGROUND_COLOR;
		sharedInstance.stockForegroundColor = STOCK_BADGE_FOREGROUND_COLOR;
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

- (CMBColorInfo *)colorInfoWithStockColors
{
	return [self colorInfoWithBackgroundColor:[self stockBackgroundColor] andForegroundColor:[self stockForegroundColor]];
}

@end

// vim:ft=objc
