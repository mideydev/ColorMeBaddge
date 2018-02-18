//#import <Foundation/Foundation.h>
#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

// hack to apply proper text color when crossfading (may not work if multiple icons animate simultaneously)
static UIColor *lastForegroundUIColor;

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

// vim:ft=objc
