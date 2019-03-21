//#import <Foundation/Foundation.h>
#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

// keep track of per-view text colors when crossfading
static NSMutableDictionary *crossfadeColors = nil;

// holds an image of the smallest size we want the badge to be
//static UIImage *minimalImage = nil;

static BOOL tweakIsOrWasPreviouslyEnabled()
{
	// sticky enable flag (disable tweak and respring to clear)
	static BOOL enabledFlag = NO;

	if (enabledFlag)
	{
		HBLogDebug(@"tweakIsOrWasPreviouslyEnabled: enabledFlag = YES");
		return YES;
	}

	if ([[CMBPreferences sharedInstance] tweakEnabled])
	{
		HBLogDebug(@"tweakIsOrWasPreviouslyEnabled: tweakEnabled = YES");
		enabledFlag = YES;
		return YES;
	}

	HBLogDebug(@"tweakIsOrWasPreviouslyEnabled: tweakEnabled = NO");
	return NO;
}

static void setCrossfadeColor(UIColor *crossfadeColor, NSString *key)
{
	@synchronized(crossfadeColors)
	{
		[crossfadeColors setObject:crossfadeColor forKey:key];
		HBLogDebug(@"setCrossfadeColor: crossfadeColors[%@] <-- %@", key, crossfadeColor);
	}
}

UIColor *getCrossfadeColor(NSString *key)
{
	UIColor *crossfadeColor = [UIColor whiteColor];

	@synchronized(crossfadeColors)
	{
		crossfadeColor = [crossfadeColors objectForKey:key];

		if (crossfadeColor)
		{
			HBLogDebug(@"getCrossfadeColor: crossfadeColors[%@] --> %@", key, crossfadeColor);
			[crossfadeColors removeObjectForKey:key];
		}
		else
		{
			HBLogDebug(@"getCrossfadeColor: no crossfade color found; falling back to default");
		}
	}

	return crossfadeColor;
}

%hook SBIconBadgeView

%group iOS10OrLess

- (void)configureForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3
{
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:_crossfadeToTextImage ]==============================");

	UIColor *crossfadeColor = getCrossfadeColor([self getCrossfadeColorKey]);

	if (arg1)
	{
		HBLogDebug(@"_crossfadeToTextImage: colorizing: arg1 = %@", arg1);
		arg1 = [[CMBSexerUpper sharedInstance] colorizeImage:arg1 withColor:crossfadeColor];
	}

	%orig();
}

%end /* iOS10OrLess */

%group iOS11

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
{
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:_crossfadeToTextImage ]==============================");

	UIColor *crossfadeColor = getCrossfadeColor([self getCrossfadeColorKey]);

	if (arg1)
	{
		HBLogDebug(@"_crossfadeToTextImage: colorizing: arg1 = %@", arg1);
		arg1 = [[CMBSexerUpper sharedInstance] colorizeImage:arg1 withColor:crossfadeColor];
	}

	%orig();
}

%end /* iOS11 */

%group iOS12OrGreater

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
{
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
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
	if (!tweakIsOrWasPreviouslyEnabled())
	{
		%orig();
		return;
	}

	HBLogDebug(@"==============================[ SBIconBadgeView:_crossfadeToTextImage ]==============================");

	UIColor *crossfadeColor = getCrossfadeColor([self getCrossfadeColorKey]);

	if (arg1)
	{
		HBLogDebug(@"_crossfadeToTextImage: colorizing: arg1 = %@", arg1);
		arg1 = [[CMBSexerUpper sharedInstance] colorizeImage:arg1 withColor:crossfadeColor];
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
		setCrossfadeColor(badgeColors.foregroundColor, [self getCrossfadeColorKey]);

	return badgeColors;
}

%new
- (void)setBadgeBackgroundColor:(CMBColorInfo *)badgeColors
{
	SBDarkeningImageView *backgroundView;
	SBIconAccessoryImage *backgroundImage;
	UIImage *colorizedImage;

	backgroundImage = MSHookIvar<SBIconAccessoryImage*>(self, "_backgroundImage");

	if (!backgroundImage)
		return;

	backgroundView = MSHookIvar<SBDarkeningImageView*>(self, "_backgroundView");

	if (!backgroundView)
		return;

	// colorize the background by recreating it from scratch.  the stock badge image
	// contains the badge, surrounded by 1 point of empty space.  we attempt to simulate
	// that by a) creating a colorized badge image 1 point smaller than the stock image,
	// then b) drawing that image within a clear image the same size as the stock image.
	// a plus to this method is that we can control the corner radius, allowing us to
	// smooth out the bump seen in the stock badge with small numbers.  it also makes
	// it easier to draw borders.

	UIView *badgeView;
	CGRect rect;
	CGFloat cornerRadius;

	// create a colorized badge image, with border if desired

	rect = self.bounds;

	rect.size.width -= backgroundImage.scale * 1.0;
	rect.size.height -= backgroundImage.scale * 1.0;

	cornerRadius = (fminf(rect.size.width, rect.size.height) - 1.0) / 2.0;

	badgeView = [[UIView alloc] initWithFrame:rect];
	badgeView.layer.cornerRadius = cornerRadius;
	badgeView.backgroundColor = badgeColors.backgroundColor;

	if ([[CMBPreferences sharedInstance] badgeBordersEnabled])
	{
		badgeView.layer.borderWidth = [[CMBPreferences sharedInstance] badgeBorderWidth];
		badgeView.layer.borderColor = badgeColors.borderColor.CGColor;
	}

	UIGraphicsBeginImageContextWithOptions(badgeView.frame.size, NO, 0.0);
	[badgeView.layer renderInContext:UIGraphicsGetCurrentContext()];
	colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// now draw the colorized badge into a larger clear image

	rect = self.bounds;

	UIGraphicsBeginImageContextWithOptions(rect.size, NO, colorizedImage.scale);
	[[UIColor clearColor] setFill];
	[colorizedImage drawAtPoint:CGPointMake(1.0, 1.0)];
	colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if (!colorizedImage)
		return;

	[backgroundView setImage:colorizedImage];
}

%new
- (void)setBadgeForegroundColor:(CMBColorInfo *)badgeColors
{
	SBDarkeningImageView *textView;
	SBIconAccessoryImage *textImage;
	UIImage *colorizedImage;

	// colorize the text by simply colorizing it

	textImage = MSHookIvar<SBIconAccessoryImage*>(self, "_textImage");

	if (!textImage)
		return;

	textView = MSHookIvar<SBDarkeningImageView*>(self, "_textView");

	if (!textView)
		return;

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

%new
- (NSString *)getCrossfadeColorKey
{
	NSString *key = [NSString stringWithFormat:@"%p", self];

	return key;
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

	crossfadeColors = [[NSMutableDictionary alloc] init];
}

// vim:ft=objc
