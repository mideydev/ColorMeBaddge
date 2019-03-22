#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"

%group CMBSwitcherView

%hook CMBSwitcherClass

- (void)updateIcon
{
	// clear any existing badge -- do this now, so they are cleared even if tweak is disabled
	for (UIView *subview in [[self imageView] subviews])
		[subview removeFromSuperview];

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	if (![[CMBPreferences sharedInstance] switcherBadgesEnabled])
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SB{Deck,Fluid}SwitcherIconImageContainerView:updateIcon ]==============================");

	%orig();

	[self createSwitcherIconBadge];
}

%new
- (void)createSwitcherIconBadge
{
	if (![[self icon] nodeIdentifier])
		return;

	if (![[objc_getClass("SBIconController") sharedInstance] iconAllowsBadging:[self icon]])
		return;

	id badgeNumberOrString = [[self icon] badgeNumberOrString];

	NSInteger badgeType = [[CMBManager sharedInstance] getBadgeValueType:badgeNumberOrString];

	HBLogDebug(@"createSwitcherIconBadge: nodeIdentifier: [%@] => badgeNumberOrString: [%@]  (badgeType = %ld)", [[self icon] nodeIdentifier], badgeNumberOrString, (long)badgeType);

	// default for numeric/special... override under numeric check below
	NSString *badgeString = (NSString *)badgeNumberOrString;

	if (kEmptyBadge == badgeType)
		return;

	if (kNumericBadge == badgeType)
	{
		// just recreate badge value from scratch

		if ([badgeNumberOrString isKindOfClass:[NSNumber class]])
			badgeString = [badgeNumberOrString stringValue];

		NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
		NSString *delocalizedBadgeString = [badgeString stringByReplacingOccurrencesOfString:groupingSeparator withString:@""];

		// no separator, because a) we could use the space, and b) binary badges get formatted when they shouldn't be
/*
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setGroupingSeparator:groupingSeparator];

		NSNumber *badgeValue = [numberFormatter numberFromString:delocalizedBadgeString];
		badgeString = [numberFormatter stringFromNumber:badgeValue];

		HBLogDebug(@"createSwitcherIconBadge: converted: [%@] => [%@] => [%@]", badgeNumberOrString, badgeValue, badgeString);
*/
		badgeString = delocalizedBadgeString;

		HBLogDebug(@"createSwitcherIconBadge: converted: [%@] => [%@]", badgeNumberOrString, badgeString);
	}

	CMBColorInfo *badgeColors = [[CMBManager sharedInstance] getBadgeColorsForIcon:[self icon]];

	// original image size
	CGFloat iconWidth = [self imageView].image.size.width;
	CGFloat iconHeight = [self imageView].image.size.height;
	CGFloat iconMaxDimension = fmaxf(iconWidth, iconHeight);

	HBLogDebug(@"iconWidth        = %0.2f", iconWidth);
	HBLogDebug(@"iconHeight       = %0.2f", iconHeight);
	HBLogDebug(@"iconMaxDimension = %0.2f", iconHeight);

	// calculated values from original image size based on home screen icons:
	// icon: 60 px
	// badge: 24 px
	// badge offset x: 46 px
	// badge offset y: -10 px

	// labelFontSize: 17
	// buttonFontSize: 18
	// smallSystemFontSize: 12
	// systemFontSize: 14

//	CGFloat badgeSize = 15.0;
//	CGFloat badgeGrowThreshold = 7.5;

	CGFloat badgeScale = iconMaxDimension / 60.0;
//	CGFloat badgeSizeScale = 1.15; // => badgeSize = 14
//	CGFloat badgeSizeScale = 1.2;  // => badgeSize = 14
//	CGFloat badgeSizeScale = 1.25; // => badgeSize = 15
//	CGFloat badgeSizeScale = 1.3;  // => badgeSize = 16
	CGFloat badgeSizeScale = (iconMaxDimension + 5.0) / iconMaxDimension;  // iconMaxDimension = 29 => badgeSize = 14 ; iconMaxDimension = 40 => badgeSize = 18
	CGFloat badgeSize = ceil(badgeScale * badgeSizeScale * 24.0);
	CGFloat badgeShift = (((badgeSizeScale - 1.0) * badgeSize) / 2.0);
	CGFloat badgeFontSize = ceil(badgeScale * badgeSizeScale * [UIFont labelFontSize]);
	CGFloat badgeOffsetX = floor(badgeScale * 46.0 - badgeShift);
	CGFloat badgeOffsetY = floor(badgeScale * -10.0 - badgeShift);
	CGFloat badgeGrowThreshold = badgeSize / 2.0;

	HBLogDebug(@"badgeScale             = %0.2f", badgeScale);
	HBLogDebug(@"badgeSizeScale         = %0.2f", badgeSizeScale);
	HBLogDebug(@"badgeSize              = %0.2f", badgeSize);
	HBLogDebug(@"badgeShift             = %0.2f", badgeShift);
	HBLogDebug(@"badgeFontSize          = %0.2f", badgeFontSize);
	HBLogDebug(@"badgeOffsetX           = %0.2f", badgeOffsetX);
	HBLogDebug(@"badgeOffsetY           = %0.2f", badgeOffsetY);
	HBLogDebug(@"badgeGrowThreshold     = %0.2f", badgeGrowThreshold);

	// create and build label
	UILabel *badge = [[UILabel alloc] initWithFrame:CGRectZero];
	badge.font = [UIFont systemFontOfSize:badgeFontSize];
	badge.text = badgeString;
	badge.textAlignment = NSTextAlignmentCenter;
	badge.backgroundColor = badgeColors.backgroundColor;
	badge.textColor = badgeColors.foregroundColor;

	[badge sizeToFit];

	HBLogDebug(@"badge.frame          = %@", NSStringFromCGRect(badge.frame));

	// adjusted values for our badge
	CGFloat x = badgeOffsetX;
	CGFloat y = badgeOffsetY;
	CGFloat w = badgeSize;
	CGFloat h = badgeSize;

	HBLogDebug(@"x = %0.2f", x);
	HBLogDebug(@"y = %0.2f", y);
	HBLogDebug(@"w = %0.2f", w);
	HBLogDebug(@"h = %0.2f", h);

	CGFloat grow = fmaxf(ceil(CGRectGetWidth(badge.frame)-badgeGrowThreshold), 0.0);

	HBLogDebug(@"x = %0.2f  y = %0.2f  w = %0.2f  h = %0.2f  grow = %0.2f", x, y, w, h, grow);

	x -= grow;
	w += grow;

	HBLogDebug(@"x = %0.2f  y = %0.2f  w = %0.2f  h = %0.2f  grow = %0.2f", x, y, w, h, grow);

	badge.frame = CGRectMake(x, y, w, h);

	HBLogDebug(@"badge.frame          = %@", NSStringFromCGRect(badge.frame));

	badge.layer.cornerRadius = (fminf(CGRectGetWidth(badge.frame), CGRectGetHeight(badge.frame)) - 1.0) / 2.0;
	badge.layer.masksToBounds = YES;

	if ([[CMBPreferences sharedInstance] badgeBordersEnabled])
	{
		badge.layer.borderWidth = 1.0;
		badge.layer.borderColor = badgeColors.borderColor.CGColor;
	}

	[[self imageView] addSubview:badge];
}

%end /* hook */

%end /* group */

%ctor
{
	Class switcherClass;

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
	{
		switcherClass = %c(SBFluidSwitcherIconImageContainerView);
	}
	else
	{
		switcherClass = %c(SBDeckSwitcherIconImageContainerView);
	}

	%init(CMBSwitcherView,CMBSwitcherClass = switcherClass);
}

// vim:ft=objc
