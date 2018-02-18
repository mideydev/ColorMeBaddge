#import <Foundation/Foundation.h>
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

// hack to apply proper text color when crossfading (may not work if multiple icons animate simultaneously)
static UIColor *lastForegroundUIColor;

static void respring(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBadges.dylib",RTLD_LAZY);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		respring,
		CFSTR("org.midey.colormebaddge/respringRequested"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);
}

%hook SBIconBadgeView

- (void)configureForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:configureForIcon ]==============================");

	CMBColorInfo *badgeColors = [self getBadgeColorsForIcon:arg1 prepareForCrossfade:NO];

	%orig();

	[self setBadgeColors:badgeColors];
}

- (void)configureAnimatedForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3 withPreparation:(id)arg4 animation:(id)arg5 completion:(id)arg6
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:configureAnimatedForIcon ]==============================");

	CMBColorInfo *badgeColors = [self getBadgeColorsForIcon:arg1 prepareForCrossfade:YES];

	%orig();

	[self setBadgeColors:badgeColors];
}

- (void)_crossfadeToTextImage:(id)arg1 withPreparation:(id)arg2 animation:(id)arg3 completion:(id)arg4
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:_crossfadeToTextImage ]==============================");

	UIColor *lastForegroundColor;
	lastForegroundColor = lastForegroundUIColor;

	if (arg1)
	{
		HBLogDebug(@"_crossfadeToTextImage: colorizing: arg1 = %@",arg1);
		arg1 = [[CMBSexerUpper sharedInstance] colorizeImage:arg1 withColor:lastForegroundColor];
	}

	%orig();
}

%new
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon prepareForCrossfade:(BOOL)prepareForCrossfade
{
	CMBColorInfo *badgeColors = [[CMBManager sharedInstance] getBadgeColorsForIcon:icon];

	if (prepareForCrossfade)
		lastForegroundUIColor = [badgeColors.foregroundColor copy];

	return badgeColors;
}

%new
- (void)setBadgeBackgroundColor:(CMBColorInfo *)badgeColors
{
	SBDarkeningImageView *backgroundView;
//	SBIconAccessoryImage *backgroundImage;
	UIImage *colorizedImage;
	UIView *bgview;
	CGRect rect;
	CGFloat cornerRadius;

	// colorize the background by recreating it from scratch (only way i've found to control corner radius)

//	backgroundImage = MSHookIvar<SBIconAccessoryImage*>(self,"_backgroundImage");
	backgroundView = MSHookIvar<SBDarkeningImageView*>(self,"_backgroundView");

	rect = self.bounds;
	cornerRadius = (fminf(rect.size.height,rect.size.width) - 1.0) / 2.0;
//	bgview = [[[UIView alloc] initWithFrame:rect] autorelease];
	bgview = [[UIView alloc] initWithFrame:rect];
	bgview.layer.cornerRadius = cornerRadius;
	bgview.backgroundColor = badgeColors.backgroundColor;

	if ([[CMBPreferences sharedInstance] badgeBordersEnabled])
	{
		bgview.layer.borderWidth = [[CMBPreferences sharedInstance] badgeBorderWidth];
		bgview.layer.borderColor = badgeColors.borderColor.CGColor;
	}

	UIGraphicsBeginImageContextWithOptions(bgview.frame.size,NO,0.0);
	[bgview.layer renderInContext:UIGraphicsGetCurrentContext()];
	colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	[backgroundView setImage:colorizedImage];
}

%new
- (void)setBadgeForegroundColor:(CMBColorInfo *)badgeColors
{
	SBDarkeningImageView *textView;
	SBIconAccessoryImage *textImage;
	UIImage *colorizedImage;

	// colorize the text by simply colorizing it

	textImage = MSHookIvar<SBIconAccessoryImage*>(self,"_textImage");

	if (!textImage)
		return;

	textView = MSHookIvar<SBDarkeningImageView*>(self,"_textView");

	colorizedImage = [[CMBSexerUpper sharedInstance] colorizeImage:textImage withColor:badgeColors.foregroundColor];

	if (!colorizedImage)
		return;

	[textView setImage:colorizedImage];
}

%new
- (void)setBadgeColors:(CMBColorInfo *)badgeColors
{
	[self setBadgeBackgroundColor:badgeColors];
	[self setBadgeForegroundColor:badgeColors];
}

%end

%hook SBIconController

- (BOOL)iconAllowsBadging:(id)arg1
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	BOOL retval = %orig();

	if ([[CMBPreferences sharedInstance] showAllBadges])
		return YES;

	return retval;
}

%end

%hook SBDownloadingIcon

- (id)appPlaceholder
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	HBLogDebug(@"==============================[ SBDownloadingIcon:appPlaceholder ]==============================");

	id retval = %orig();

	[[CMBManager sharedInstance] clearCachedColorsForApplication:[retval applicationBundleID]];

	return retval;
}

- (void)setApplicationPlaceholder:(id)arg1
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBDownloadingIcon:setApplicationPlaceholder ]==============================");

	%orig();

	[[CMBManager sharedInstance] clearCachedColorsForApplication:[arg1 applicationBundleID]];
}

%end

%hook SBDeckSwitcherIconImageContainerView

- (void)updateIcon
{
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

	HBLogDebug(@"==============================[ SBDeckSwitcherIconImageContainerView:updateIcon ]==============================");

	%orig();

	[self createSwitcherIconBadge];
}

%new
- (void)createSwitcherIconBadge
{
	if (![[objc_getClass("SBIconController") sharedInstance] iconAllowsBadging:[self icon]])
		return;

	id badgeNumberOrString = [[self icon] badgeNumberOrString];

	NSInteger badgeType = [[CMBManager sharedInstance] getBadgeValueType:badgeNumberOrString];

	HBLogDebug(@"createSwitcherIconBadge: nodeIdentifier: [%@] => badgeNumberOrString: [%@]  (badgeType = %ld)",[[self icon] nodeIdentifier],badgeNumberOrString,(long)badgeType);

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

		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setGroupingSeparator:groupingSeparator];

		NSNumber *badgeValue = [numberFormatter numberFromString:delocalizedBadgeString];
		badgeString = [numberFormatter stringFromNumber:badgeValue];

		HBLogDebug(@"createSwitcherIconBadge: converted: [%@] => [%@] => [%@]",badgeNumberOrString,badgeValue,badgeString);
	}

	CMBColorInfo *badgeColors = [[CMBManager sharedInstance] getBadgeColorsForIcon:[self icon]];

	// original image size
	CGFloat iconWidth = [self imageView].image.size.width;
	CGFloat iconHeight = [self imageView].image.size.height;
	CGFloat iconMaxDimension = fmaxf(iconWidth,iconHeight);

	HBLogDebug(@"iconWidth        = %0.2f",iconWidth);
	HBLogDebug(@"iconHeight       = %0.2f",iconHeight);
	HBLogDebug(@"iconMaxDimension = %0.2f",iconHeight);

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

	HBLogDebug(@"badgeScale             = %0.2f",badgeScale);
	HBLogDebug(@"badgeSizeScale         = %0.2f",badgeSizeScale);
	HBLogDebug(@"badgeSize              = %0.2f",badgeSize);
	HBLogDebug(@"badgeShift             = %0.2f",badgeShift);
	HBLogDebug(@"badgeFontSize          = %0.2f",badgeFontSize);
	HBLogDebug(@"badgeOffsetX           = %0.2f",badgeOffsetX);
	HBLogDebug(@"badgeOffsetY           = %0.2f",badgeOffsetY);
	HBLogDebug(@"badgeGrowThreshold     = %0.2f",badgeGrowThreshold);

	// create and build label
	UILabel *badge = [[UILabel alloc] initWithFrame:CGRectZero];
	badge.font = [UIFont systemFontOfSize:badgeFontSize];
	badge.text = badgeString;
	badge.textAlignment = NSTextAlignmentCenter;
	badge.backgroundColor = badgeColors.backgroundColor;
	badge.textColor = badgeColors.foregroundColor;

	[badge sizeToFit];

	HBLogDebug(@"badge.frame          = %@",NSStringFromCGRect(badge.frame));

	// adjusted values for our badge
	CGFloat x = badgeOffsetX;
	CGFloat y = badgeOffsetY;
	CGFloat w = badgeSize;
	CGFloat h = badgeSize;

	HBLogDebug(@"x = %0.2f",x);
	HBLogDebug(@"y = %0.2f",y);
	HBLogDebug(@"w = %0.2f",w);
	HBLogDebug(@"h = %0.2f",h);

	CGFloat grow = fmaxf(ceil(CGRectGetWidth(badge.frame)-badgeGrowThreshold),0.0);

	HBLogDebug(@"x = %0.2f  y = %0.2f  w = %0.2f  h = %0.2f  grow = %0.2f",x,y,w,h,grow);

	x -= grow;
	w += grow;

	HBLogDebug(@"x = %0.2f  y = %0.2f  w = %0.2f  h = %0.2f  grow = %0.2f",x,y,w,h,grow);

	badge.frame = CGRectMake(x,y,w,h);

	HBLogDebug(@"badge.frame          = %@",NSStringFromCGRect(badge.frame));

	badge.layer.cornerRadius = (fminf(CGRectGetWidth(badge.frame),CGRectGetHeight(badge.frame)) - 1.0) / 2.0;
	badge.layer.masksToBounds = YES;

	if ([[CMBPreferences sharedInstance] badgeBordersEnabled])
	{
		badge.layer.borderWidth = 1.0; 
		badge.layer.borderColor = badgeColors.borderColor.CGColor;
	}

	[[self imageView] addSubview:badge];
}

%end

// vim:ft=objc
