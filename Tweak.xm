#import <Foundation/Foundation.h>
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

// hack to apply proper text color when crossfading (may not work if multiple icons animate simultaneously)
//static CGFloat lastForegroundRGBA[4];
static UIColor *lastForegroundUIColor;

#if 0
static void setLastForegroundRGBA(UIColor *color)
{
	HBLogDebug(@"setLastForegroundRGBA: %@",color);

	CGColorRef colorref = [color CGColor];

	int numComponents = CGColorGetNumberOfComponents(colorref);

	if (4 != numComponents)
		return;

	const CGFloat *components = CGColorGetComponents(colorref);

	memcpy(lastForegroundRGBA,components,sizeof(lastForegroundRGBA));
}

static UIColor *getLastForegroundRGBA()
{
	CGFloat components[4];

	memcpy(components,lastForegroundRGBA,sizeof(lastForegroundRGBA));

	UIColor *color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];

	HBLogDebug(@"getLastForegroundRGBA: %@",color);

	return color;
}
#endif

static void respring(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor
{
//	setLastForegroundRGBA(realWhiteColor);

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

	HBLogDebug(@"==============================[ configureForIcon ]==============================");

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

	HBLogDebug(@"==============================[ configureAnimatedForIcon ]==============================");

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

	HBLogDebug(@"==============================[ _crossfadeToTextImage ]==============================");

	// FIXME
	UIColor *lastForegroundColor;
//	lastForegroundColor = getLastForegroundRGBA();
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
	{
		// FIXME
//		setLastForegroundRGBA(badgeColors.foregroundColor);
//		if (lastForegroundUIColor)
//			[lastForegroundUIColor release];
		lastForegroundUIColor = [badgeColors.foregroundColor copy];
	}

	return badgeColors;
}

%new
- (void)setBadgeBackgroundColor:(UIColor *)backgroundColor
{
	SBDarkeningImageView *backgroundView;
	SBIconAccessoryImage *backgroundImage;
	UIImage *colorizedImage;
	UIView *bgview;
	CGRect rect;
	CGFloat cornerRadius;

	// colorize the background by recreating it from scratch (only way i've found to control corner radius)

	backgroundImage = MSHookIvar<SBIconAccessoryImage*>(self,"_backgroundImage");
	backgroundView = MSHookIvar<SBDarkeningImageView*>(self,"_backgroundView");

	rect = self.bounds;
	cornerRadius = (fminf(rect.size.height,rect.size.width) - 1.0) / 2.0;
//	bgview = [[[UIView alloc] initWithFrame:rect] autorelease];
	bgview = [[UIView alloc] initWithFrame:rect];
	bgview.layer.cornerRadius = cornerRadius;
	bgview.backgroundColor = backgroundColor;
	UIGraphicsBeginImageContextWithOptions(bgview.frame.size,NO,0.0);
	[bgview.layer renderInContext:UIGraphicsGetCurrentContext()];
	colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	[backgroundView setImage:colorizedImage];
}

%new
- (void)setBadgeForegroundColor:(UIColor *)foregroundColor
{
	SBDarkeningImageView *textView;
	SBIconAccessoryImage *textImage;
	UIImage *colorizedImage;

	// colorize the text by simply colorizing it

	textImage = MSHookIvar<SBIconAccessoryImage*>(self,"_textImage");

	if (!textImage)
		return;

	textView = MSHookIvar<SBDarkeningImageView*>(self,"_textView");

	colorizedImage = [[CMBSexerUpper sharedInstance] colorizeImage:textImage withColor:foregroundColor];

	if (!colorizedImage)
		return;

	[textView setImage:colorizedImage];
}

%new
- (void)setBadgeColors:(CMBColorInfo *)badgeColors
{
	[self setBadgeBackgroundColor:badgeColors.backgroundColor];
	[self setBadgeForegroundColor:badgeColors.foregroundColor];
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

	HBLogDebug(@"==============================[ appPlaceholder ]==============================");

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

	HBLogDebug(@"==============================[ setApplicationPlaceholder ]==============================");

	%orig();

	[[CMBManager sharedInstance] clearCachedColorsForApplication:[arg1 applicationBundleID]];
}

%end

// vim:ft=objc
