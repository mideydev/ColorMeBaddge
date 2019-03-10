#import "SpringBoard.h"
#import "CMBPreferences.h"
#import "CMBManager.h"
#import "CMBSexerUpper.h"
#import "external/ColorBadges/ColorBadges.h"
#import "external/ColorBanners2/CBRColoringInfo.h"
#import "external/ColorBanners2/CBRPrefsManager.h"
#import <dlfcn.h>

#define GETDARK(rgb) ((rgb >> 24) & 0xFF)

BOOL hasColorBanners = NO;

%ctor
{
	void *cb1,*cb2;

	cb1 = dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBanners.dylib",RTLD_LAZY);
	cb2 = dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBanners2.dylib",RTLD_LAZY);

	hasColorBanners = (cb1 || cb2) ? YES : NO;

	HBLogDebug(@"(cb1 = %@ || cb2 = %@) ==> hasColorBanners = %@",cb1?@"YES":@"NO",cb2?@"YES":@"NO",hasColorBanners?@"YES":@"NO");
}

%hook CBRColorCache

- (int)colorForIdentifier:(id)arg1 image:(id)arg2
{
	if (!hasColorBanners)
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] provideColorsForColorBanners])
	{
		return %orig();
	}

	HBLogDebug(@"----------[ CBRColorCache:colorForIdentifier ]----------");

	SBIcon *icon;
	CMBColorInfo *bannerColors = nil;

	icon = [[[objc_getClass("SBIconController") sharedInstance] model] applicationIconForBundleIdentifier:arg1];

	HBLogDebug(@"colorForIdentifier: [%@] icon: %@",arg1,icon);

	// if no icon, it might be a today widget.  attempt to determine app by dropping last component of identifier.
	if (!icon)
	{
		NSMutableArray *pieces = (NSMutableArray *)[arg1 componentsSeparatedByString:@"."];

		HBLogDebug(@"colorForIdentifier: pieces count = %ld",(long)[pieces count]);

		if ([pieces count] > 1)
		{
			[pieces removeLastObject];

			NSString *notToday = [pieces componentsJoinedByString:@"."];

			icon = [[[objc_getClass("SBIconController") sharedInstance] model] applicationIconForBundleIdentifier:notToday];

			HBLogDebug(@"colorForIdentifier: [%@] icon: %@",notToday,icon);
		}
	}

	if (icon)
	{
		HBLogDebug(@"colorForIdentifier: using icon");
		bannerColors = [[CMBManager sharedInstance] getBadgeColorsForIcon:icon];
	}
	else
	{
		HBLogDebug(@"colorForIdentifier: using image");
		bannerColors = [[CMBManager sharedInstance] getPreferredAppBadgeColorsForImage:arg2];

		if (bannerColors)
			bannerColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:bannerColors.backgroundColor];
	}

	if (!bannerColors)
	{
		HBLogDebug(@"colorForIdentifier: no ColorMeBaddge colors; falling back to ColorBanners");
		return %orig();
	}

	int drgb = [[CMBSexerUpper sharedInstance] DRGBFromUIColor:bannerColors.backgroundColor];

	HBLogDebug(@"colorForIdentifier: returning drgb = %d (%d,%d,%d,%d)",drgb,GETDARK(drgb),GETRED(drgb),GETGREEN(drgb),GETBLUE(drgb));

	return drgb;
}

- (int)colorForImage:(id)arg1
{
	if (!hasColorBanners)
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] provideColorsForColorBanners])
	{
		return %orig();
	}

	HBLogDebug(@"----------[ CBRColorCache:colorForImage ]----------");

	CMBColorInfo *bannerColors = nil;

	bannerColors = [[CMBManager sharedInstance] getPreferredAppBadgeColorsForImage:arg1];

	if (bannerColors)
		bannerColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:bannerColors.backgroundColor];

	if (!bannerColors)
	{
		HBLogDebug(@"colorForImage: no ColorMeBaddge colors; falling back to ColorBanners");
		return %orig();
	}

	int drgb = [[CMBSexerUpper sharedInstance] DRGBFromUIColor:bannerColors.backgroundColor];

	HBLogDebug(@"colorForImage: returning drgb = %d (%d,%d,%d,%d)",drgb,GETDARK(drgb),GETRED(drgb),GETGREEN(drgb),GETBLUE(drgb));

	return drgb;
}

+ (_Bool)isDarkColor:(int)arg1
{
	if (!hasColorBanners)
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	if (![[CMBPreferences sharedInstance] provideColorsForColorBanners])
	{
		return %orig();
	}

	HBLogDebug(@"----------[ CBRColorCache:isDarkColor ]----------");

	HBLogDebug(@"isDarkColor: arg1 = %d (%d,%d,%d,%d)",arg1,GETDARK(arg1),GETRED(arg1),GETGREEN(arg1),GETBLUE(arg1));

	BOOL isDark = (GETDARK(arg1)) ? YES : NO;

	HBLogDebug(@"isDarkColor: returning %@",isDark?@"YES":@"NO");

	return isDark;
}

%end

%hook CBRColoringInfo

- (void)setContrastColor:(UIColor *)color
{
	if (!hasColorBanners)
	{
		%orig();
		return;
	}

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	if (![[CMBPreferences sharedInstance] provideColorsForColorBanners])
	{
		%orig();
		return;
	}

	UIColor *realContrastColor = [self realColorForColor:color];

	%orig(realContrastColor);
}

- (void)setLongLookContrastColor:(UIColor *)color
{
	if (!hasColorBanners)
	{
		%orig();
		return;
	}

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	if (![[CMBPreferences sharedInstance] provideColorsForColorBanners])
	{
		%orig();
		return;
	}

	UIColor *realContrastColor = [self realColorForColor:color];

	%orig(realContrastColor);
}

%new
- (UIColor *)realColorForColor:(UIColor *)color
{
	HBLogDebug(@"----------[ CBRColoringInfo:realColorForColor ]----------");

	HBLogDebug(@"realColorForColor: %@",color);

	UIColor *realContrastColor = color;

	switch ([[CMBPreferences sharedInstance] badgeColorAdjustmentType])
	{
		case kShadeForWhiteText:
			HBLogDebug(@"realColorForColor: kShadeForWhiteText: using white");
			realContrastColor = [UIColor whiteColor];
			break;

		case kTintForBlackText:
			HBLogDebug(@"realColorForColor: kTintForBlackText: using black");
			realContrastColor = [UIColor blackColor];
			break;

		case kNoAdjustment:
		default:
			CGFloat tolerance = 0.01;
			BOOL isLightColor = NO;

			Class cbrPrefsManager = %c(CBRPrefsManager);

			// check for ColorBanners2 >= 1.2.2
			if (cbrPrefsManager && [[cbrPrefsManager sharedInstance] respondsToSelector:@selector(bannerLightColor)])
			{
				// 1.2.2+ has user-defined light color settings.  since we (currently) do not know if we are in a
				// banner, the notification center, or the lock screen, the best we can do is check if the color
				// being set is similar to known colors from the settings.  this is not guaranteed to be correct.
				// also, need to check whether the color is similar to the corresponding color we return here,
				// since it seems to be copied/inherited in some cases.

				HBLogDebug(@"realColorForColor: bannerLightColor : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] bannerLightColor]));
				HBLogDebug(@"realColorForColor: bannerDarkColor  : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] bannerDarkColor]));
				HBLogDebug(@"realColorForColor: lsLightColor     : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] lsLightColor]));
				HBLogDebug(@"realColorForColor: lsDarkColor      : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] lsDarkColor]));
				HBLogDebug(@"realColorForColor: ncLightColor     : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] ncLightColor]));
				HBLogDebug(@"realColorForColor: ncDarkColor      : %@", UIColorFromRGB([[cbrPrefsManager sharedInstance] ncDarkColor]));
				HBLogDebug(@"realColorForColor: whiteColor       : %@", [UIColor whiteColor]);
				HBLogDebug(@"realColorForColor: blackColor       : %@", [UIColor blackColor]);
				HBLogDebug(@"realColorForColor: color            : %@", color);

				if ([self color:color isSimilarToColor:UIColorFromRGB([[cbrPrefsManager sharedInstance] bannerLightColor]) withTolerance:tolerance] ||
					[self color:color isSimilarToColor:UIColorFromRGB([[cbrPrefsManager sharedInstance] lsLightColor]) withTolerance:tolerance] ||
					[self color:color isSimilarToColor:UIColorFromRGB([[cbrPrefsManager sharedInstance] ncLightColor]) withTolerance:tolerance] ||
					[self color:color isSimilarToColor:[UIColor whiteColor] withTolerance:tolerance])
				{
					isLightColor = YES;
				}
			}
			else
			{
				if ([self color:color isSimilarToColor:[UIColor whiteColor] withTolerance:tolerance])
				{
					isLightColor = YES;
				}
			}

			if (isLightColor)
			{
				HBLogDebug(@"realColorForColor: kNoAdjustment: color being set is similar to a ColorBanners light color; using white");
				realContrastColor = [UIColor whiteColor];
			}
			else
			{
				HBLogDebug(@"realColorForColor: kNoAdjustment: color being set is NOT similar to a ColorBanners light color; using black");
				realContrastColor = [UIColor blackColor];
			}
			break;
	}

	return realContrastColor;
}

%new
- (BOOL)color:(UIColor *)color1 isSimilarToColor:(UIColor *)color2 withTolerance:(float)tolerance
{
	CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
	CGFloat rdiff, gdiff, bdiff, adiff;

	[color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

	rdiff = fabs(r1 - r2);
	gdiff = fabs(g1 - g2);
	bdiff = fabs(b1 - b2);
	adiff = fabs(a1 - a2);

	BOOL similar = (rdiff <= tolerance) && (gdiff <= tolerance) && (bdiff <= tolerance) && (adiff <= tolerance);

	HBLogDebug(@"color:isSimilarToColor: difference: (%0.2f, %0.2f, %0.2f, %0.2f) (tolerance: %0.2f) => %@similar", rdiff, gdiff, bdiff, adiff, tolerance, (similar) ? @"" : @"NOT ");

	return similar;
}

%end

// vim:ft=objc
