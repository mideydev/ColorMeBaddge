//#import <Foundation/Foundation.h>
#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

// hack to apply proper text color when crossfading (may not work if multiple icons animate simultaneously)
static UIColor *lastForegroundUIColor;

%hook SBIconBadgeView

%group iOS10OrLess

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

%end /* iOS10OrLess */

%group iOS11

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
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

- (void)configureAnimatedForIcon:(id)arg1 infoProvider:(id)arg2 withPreparation:(id)arg3 animation:(id)arg4 completion:(id)arg5
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

%end /* iOS11 */

%group iOS12OrGreater

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
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

- (void)configureAnimatedForIcon:(id)arg1 infoProvider:(id)arg2 animator:(id)arg3
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

- (void)_crossfadeToTextImage:(id)arg1 animator:(id)arg2
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

%end

%new
- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon prepareForCrossfade:(BOOL)prepareForCrossfade
{
	CMBColorInfo *badgeColors = nil;

	CMBIconInfo *iconInfo = [[CMBIconInfo sharedInstance] getIconInfo:icon];

	if (iconInfo.isApplication == NO)
	{
		NSInteger folderBadgeBackgroundType = [[CMBPreferences sharedInstance] folderBadgeBackgroundType];

		if (folderBadgeBackgroundType == kFBB_RandomBadge)
		{
			UIView *rootView;

			for (rootView = self; [rootView superview]; rootView = [rootView superview]);

			HBLogDebug(@"[%@] folder self view: %@", iconInfo.nodeIdentifier, NSStringFromClass([self class]));
			HBLogDebug(@"[%@] folder supr view: %@", iconInfo.nodeIdentifier, NSStringFromClass([[self superview] class]));
			HBLogDebug(@"[%@] folder root view: %@", iconInfo.nodeIdentifier, NSStringFromClass([rootView class]));

			// ios 12:
			// SBHomeScreenWindow => normal view
			// SBFolderIconView => 3d touch?

			if (![rootView isKindOfClass:NSClassFromString(@"SBHomeScreenWindow")])
			{
				badgeColors = [[CMBManager sharedInstance] getBadgeColorsForFolderUsingColorsFromRandomBadge:iconInfo preferCachedColors:YES];
			}
		}
	}

	if (badgeColors == nil)
		badgeColors = [[CMBManager sharedInstance] getBadgeColorsForIcon:icon];

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
	// reduce corner radius by 1 pixel to smooth out bump seen in stock badge
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

%ctor
{
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0"))
	{
		%init(iOS12OrGreater);
	}
	else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
	{
		%init(iOS11);
	}
	else
	{
		%init(iOS10OrLess);
	}

	%init;
}

// vim:ft=objc
