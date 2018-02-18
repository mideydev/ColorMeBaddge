#import "SpringBoard.h"
#import "CMBPreferences.h"
#import "CMBManager.h"
#import "CMBSexerUpper.h"
#import "external/ColorBadges/ColorBadges.h"
#import "external/ColorBanners2/CBRColoringInfo.h"
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

	HBLogDebug(@"----------[ CBRColoringInfo:setContrastColor ]----------");

	HBLogDebug(@"setContrastColor: caller wants to set color: %@",color);

	UIColor *realContrastColor = color;

	switch ([[CMBPreferences sharedInstance] badgeColorAdjustmentType])
	{
		case kShadeForWhiteText:
			HBLogDebug(@"setContrastColor: kShadeForWhiteText: using white");
			realContrastColor = [UIColor whiteColor];
			break;

		case kTintForBlackText:
			HBLogDebug(@"setContrastColor: kTintForBlackText: using black");
			realContrastColor = [UIColor blackColor];
			break;

		case kNoAdjustment:
		default:
			if ([color isEqual:[UIColor whiteColor]])
			{
				HBLogDebug(@"setContrastColor: kNoAdjustment: color being set is equal to white; using white");
				realContrastColor = [UIColor whiteColor];
			}
			else
			{
				HBLogDebug(@"setContrastColor: kNoAdjustment: color being set is NOT equal to white; using black");
				realContrastColor = [UIColor blackColor];
			}
			break;
	}

	%orig(realContrastColor);
}

%end

// vim:ft=objc
