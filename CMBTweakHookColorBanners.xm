#import "SpringBoard.h"
#import "CMBPreferences.h"
#import "CMBManager.h"
#import "CMBSexerUpper.h"
#import "external/ColorBadges/ColorBadges.h"
#import "external/ColorBanners2/CBRColoringInfo.h"
#import <dlfcn.h>

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
	}

	if (!bannerColors.backgroundColor)
	{
		HBLogDebug(@"colorForIdentifier: no ColorMeBaddge colors; falling back to ColorBanners");
		return %orig();
	}

	int rgb = [[CMBSexerUpper sharedInstance] RGBFromUIColor:bannerColors.backgroundColor];

	HBLogDebug(@"colorForIdentifier: rgb = %d",rgb);

	return rgb;
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

	if (!bannerColors.backgroundColor)
	{
		HBLogDebug(@"colorForImage: no ColorMeBaddge colors; falling back to ColorBanners");
		return %orig();
	}

	int rgb = [[CMBSexerUpper sharedInstance] RGBFromUIColor:bannerColors.backgroundColor];

	HBLogDebug(@"colorForImage: rgb = %d",rgb);

	return rgb;
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

	UIColor *backgroundColor = UIColorFromRGB(arg1);

	UIColor *foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];

	int rgb = [[CMBSexerUpper sharedInstance] RGBFromUIColor:foregroundColor];

	// foreground color chosen based on background color darkness will either be white (rgb = 16777215) or black (rgb = 0).
	// so we determine whether the background color is dark, by checking whether the foreground color is light
	BOOL backgroundColorIsDark = (rgb) ? YES : NO;

	HBLogDebug(@"isDarkColor: rgb = %d  (backgroundColorIsDark = %@)",rgb,backgroundColorIsDark?@"YES":@"NO");

	return backgroundColorIsDark;
}

%end

%hook CBRColoringInfo

- (UIColor *)contrastColor
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

	HBLogDebug(@"----------[ CBRColoringInfo:contrastColor ]----------");

	HBLogDebug(@"contrastColor: current color: %@",[self color]);

	UIColor *foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:[self color]];

	HBLogDebug(@"contrastColor: contrast color: %@",foregroundColor);

	return foregroundColor;
}

%end

// vim:ft=objc
