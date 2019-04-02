#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"

#define ANEMONE_CLASS objc_getClass("ANEMSettingsManager")

@implementation CMBManager

- (CMBManager *)init
{
	self = [super init];

	if (self)
	{
		cachedAppBadgeColors = [[NSMutableDictionary alloc] init];
		cachedRandomFolderBadgeColors = [[NSMutableDictionary alloc] init];

		dlopen("/Library/MobileSubstrate/DynamicLibraries/AnemoneCore.dylib", RTLD_LAZY);

		if (ANEMONE_CLASS)
		{
			if ([ANEMONE_CLASS respondsToSelector:@selector(sharedManager)])
			{
				if ([[ANEMONE_CLASS sharedManager] respondsToSelector:@selector(addEventHandler:)])
				{
					[[ANEMONE_CLASS sharedManager] addEventHandler:self];
				}
			}
		}
	}

	return self;
}

+ (CMBManager *)sharedInstance
{
	static CMBManager *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBManager alloc] init];
		// Do any other initialisation stuff here
	});

	return sharedInstance;
}

- (CMBColorInfo *)getPreferredAppBadgeForegroundColor:(CMBColorInfo *)currentColors
{
	UIColor *backgroundColor = currentColors.backgroundColor;
	UIColor *foregroundColor = currentColors.foregroundColor;

	if (!backgroundColor)
		backgroundColor = [[CMBColorInfo sharedInstance] stockBackgroundColor];

	switch ([[CMBPreferences sharedInstance] appBadgeForegroundType])
	{
		case kABF_FixedColor:
			foregroundColor = [[CMBPreferences sharedInstance] appBadgeForegroundColor];
			break;

		case kABF_ByBrightness:
			backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
			foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			break;

		case kABF_ByAlgorithmElseFixedColor:
			if (foregroundColor)
			{
				foregroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeForegroundColorByPreference:foregroundColor];
			}
			else
			{
				foregroundColor = [[CMBPreferences sharedInstance] appBadgeForegroundColor];
			}
			break;

		case kABF_ByAlgorithmElseBrightness:
			if (foregroundColor)
			{
				foregroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeForegroundColorByPreference:foregroundColor];
			}
			else
			{
				backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
				foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			}
			break;
	}

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:foregroundColor];

	return badgeColors;
}

#if 0
- (UIColor *)convertUIColorToUIDeviceRGBColorSpace:(UIColor *)color
{
	if (!color)
		return color;

	HBLogDebug(@"convertToUIDeviceRGBColorSpace: color       = %@", color);

	HBLogDebug(@"convertToUIDeviceRGBColorSpace: [color CGColor] = %@", [color CGColor]);

	CGColorSpaceRef colorSpace = CGColorGetColorSpace([color CGColor]);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);

	HBLogDebug(@"convertToUIDeviceRGBColorSpace: colorSpace = %@", colorSpace);
	HBLogDebug(@"convertToUIDeviceRGBColorSpace: colorSpaceModel = %d", colorSpaceModel);

	CGColorSpaceRef deviceColorSpace = CGColorSpaceCreateDeviceRGB();

	CGColorRef deviceColorRef = CGColorCreateCopyByMatchingToColorSpace(deviceColorSpace, kCGRenderingIntentPerceptual, [color CGColor], NULL);

	UIColor *deviceColor = [UIColor colorWithCGColor:deviceColorRef];

	HBLogDebug(@"convertToUIDeviceRGBColorSpace: deviceColor = %@", deviceColor);

	return deviceColor;
}

- (CMBColorInfo *)convertBadgeColorsToUIDeviceRGBColorSpace:(CMBColorInfo *)currentColors
{
	currentColors.backgroundColor = [self convertUIColorToUIDeviceRGBColorSpace:currentColors.backgroundColor];
	currentColors.foregroundColor = [self convertUIColorToUIDeviceRGBColorSpace:currentColors.foregroundColor];
	currentColors.borderColor = [self convertUIColorToUIDeviceRGBColorSpace:currentColors.borderColor];

	return currentColors;
}
#endif

#if 0
- (UIColor *)adjustColorForDisplay:(UIColor *)color
{
	if (!color)
		return color;

	HBLogDebug(@"adjustColorForDisplay: color = %@", color);

	CGFloat r, g, b, a;
	CGFloat R, G, B;

	[color getRed:&r green:&g blue:&b alpha:&a];

	R = fmaxf(0.0, fminf(1.0, r));
	G = fmaxf(0.0, fminf(1.0, g));
	B = fmaxf(0.0, fminf(1.0, b));

	HBLogDebug(@"adjustColorForDisplay: (r,g,b) = (%0.2f,%0.2f,%0.2f) => (%0.2f,%0.2f,%0.2f)", r, g, b, R, G, B);

	UIColor *displayColor = [UIColor colorWithRed:R green:G blue:B alpha:a];

	HBLogDebug(@"adjustColorForDisplay: displayColor = %@", displayColor);

	return displayColor;
}

- (CMBColorInfo *)adjustColorsForDisplay:(CMBColorInfo *)currentColors
{
	currentColors.backgroundColor = [self adjustColorForDisplay:currentColors.backgroundColor];
	currentColors.foregroundColor = [self adjustColorForDisplay:currentColors.foregroundColor];
	currentColors.borderColor = [self adjustColorForDisplay:currentColors.borderColor];

	return currentColors;
}
#endif

- (CMBColorInfo *)getPreferredAppBadgeColorsForImage:(UIImage *)image
{
	CMBColorInfo *badgeColors = nil;

	switch ([[CMBPreferences sharedInstance] appBadgeBackgroundType])
	{
		case kABB_FixedColor:
			badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[[CMBPreferences sharedInstance] appBadgeBackgroundColor] andForegroundColor:nil];
			break;

		case kABB_CCColorCube:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingCCColorCube:image];
			badgeColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeBackgroundColorByPreference:badgeColors.backgroundColor];
			break;

		case kABB_LEColorPicker:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingLEColorPicker:image];
			badgeColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeBackgroundColorByPreference:badgeColors.backgroundColor];
			break;

		case kABB_Boover:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingBooverAlgorithm:image];
			badgeColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeBackgroundColorByPreference:badgeColors.backgroundColor];
			break;

		case kABB_ColorBadges:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingColorBadges:image];
			badgeColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeBackgroundColorByPreference:badgeColors.backgroundColor];
			break;

		case kABB_Chameleon:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingChameleon:image];
			badgeColors.backgroundColor = [[CMBSexerUpper sharedInstance] adjustAppBadgeBackgroundColorByPreference:badgeColors.backgroundColor];
			break;

		case kABB_RandomColor:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingRandom];
			break;
	}

//	badgeColors.backgroundColor = [self adjustColorForDisplay:badgeColors.backgroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getPreferredAppBadgeColorsForIcon:(CMBIconInfo *)iconInfo
{
	UIImage *iconImage = nil;

	// could be folder minigrid

	if (iconInfo.isApplication)
	{
		iconImage = [iconInfo.icon getIconImage:1];

		if ([[CMBPreferences sharedInstance] useUnmaskedIcons])
		{
			UIImage *unmaskedIconImage = [iconInfo.icon getUnmaskedIconImage:1];

			if (unmaskedIconImage)
				iconImage = unmaskedIconImage;
		}
	}
	else
	{
		iconImage = [iconInfo.icon _miniIconGridForPage:0];
	}

	CMBColorInfo *badgeColors = [self getPreferredAppBadgeColorsForImage:iconImage];

	if (badgeColors)
		return badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithStockColors];

	return badgeColors;
}

- (UIColor *)getPreferredBorderColor:(CMBColorInfo *)currentColors
{
	if (currentColors.borderColor)
		return currentColors.borderColor;

	UIColor *borderColor = currentColors.foregroundColor;

	switch ([[CMBPreferences sharedInstance] badgeBorderType])
	{
		case kBB_FixedColor:
			borderColor = [[CMBPreferences sharedInstance] badgeBorderColor];
			break;

		case kBB_ByBrightness:
			borderColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:currentColors.backgroundColor];
			break;

		case kBB_BadgeForegroundColor:
			borderColor = currentColors.foregroundColor;
			break;

		case kBB_TintedBadgeBackgroundColor:
		case kBB_ShadedBadgeBackgroundColor:
			borderColor = [[CMBSexerUpper sharedInstance] adjustBorderColorByPreference:currentColors.backgroundColor];
			break;
	}

	return borderColor;
}

- (CMBColorInfo *)getBadgeColorsForApplicationIcon:(CMBIconInfo *)iconInfo
{
	CMBColorInfo *badgeColors = [cachedAppBadgeColors objectForKey:iconInfo.nodeIdentifier];

	if (badgeColors)
		return badgeColors;

	HBLogDebug(@"getBadgeColorsForApplicationIcon: scanning app: %@", iconInfo.nodeIdentifier);

//	[[CMBSexerUpper sharedInstance] saveImage:iconInfo.image withName:iconInfo.nodeIdentifier andPostfix:@"-masked"];
//	[[CMBSexerUpper sharedInstance] saveImage:iconInfo.unmaskedImage withName:iconInfo.nodeIdentifier andPostfix:@"-unmasked"];

	badgeColors = [self getPreferredAppBadgeForegroundColor:[self getPreferredAppBadgeColorsForIcon:iconInfo]];

	badgeColors.borderColor = [self getPreferredBorderColor:badgeColors];

	HBLogDebug(@"getBadgeColorsForApplicationIcon: app: %@  backgroundColor = %@", iconInfo.nodeIdentifier, badgeColors.backgroundColor);

	[cachedAppBadgeColors setObject:badgeColors forKey:iconInfo.nodeIdentifier];

	return badgeColors;
}

- (NSInteger)getBadgeValueType:(id)badgeNumberOrString
{
	if (!badgeNumberOrString)
	{
		HBLogDebug(@"getBadgeValueType: kEmptyBadge (nil)");
		return kEmptyBadge;
	}

	if ([badgeNumberOrString isKindOfClass:[NSNumber class]])
	{
		if ([badgeNumberOrString integerValue] <= 0)
		{
			HBLogDebug(@"getBadgeValueType: kEmptyBadge (non-positive NSNumber): [%@]", NSStringFromClass([badgeNumberOrString class]));
			return kEmptyBadge;
		}

		HBLogDebug(@"getBadgeValueType: kNumericBadge (NSNumber): [%@]", NSStringFromClass([badgeNumberOrString class]));
		return kNumericBadge;
	}

	if (![badgeNumberOrString isKindOfClass:[NSString class]])
	{
		HBLogDebug(@"getBadgeValueType: kEmptyBadge (not NSString): [%@]", NSStringFromClass([badgeNumberOrString class]));
		return kEmptyBadge;
	}

	NSString *badgeString = (NSString *)badgeNumberOrString;

	if ([badgeString isEqualToString:@""])
	{
		HBLogDebug(@"getBadgeValueType: kEmptyBadge (empty string)");
		return kEmptyBadge;
	}

	// only want non-negative integers

	NSScanner *scanner;
	NSInteger badgeValue;
	BOOL isNumeric;

	// 1. check string as-is

	HBLogDebug(@"getBadgeValueType: 1. checking string for numeracy as-is: [%@]", badgeString);

	scanner = [NSScanner scannerWithString:badgeString];
	isNumeric = [scanner scanInteger:&badgeValue] && [scanner isAtEnd];

	HBLogDebug(@"getBadgeValueType: 1. isNumeric = %@ / badgeValue = %ld", isNumeric ? @"YES" : @"NO", (long)badgeValue);

	if ((isNumeric) && (badgeValue >= 0))
	{
		HBLogDebug(@"getBadgeValueType: kNumericBadge");
		return kNumericBadge;
	}

	// 2. check string without localized separators

	NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
	NSString *delocalizedBadgeString = [badgeString stringByReplacingOccurrencesOfString:groupingSeparator withString:@""];

	HBLogDebug(@"getBadgeValueType: 2. checking delocalized string: [%@] - [%@] => [%@]", badgeString, groupingSeparator, delocalizedBadgeString);

	scanner = [NSScanner scannerWithString:delocalizedBadgeString];
	isNumeric = [scanner scanInteger:&badgeValue] && [scanner isAtEnd];

	HBLogDebug(@"getBadgeValueType: 2. isNumeric = %@ / badgeValue = %ld", isNumeric ? @"YES" : @"NO", (long)badgeValue);

	if ((isNumeric) && (badgeValue >= 0))
	{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setGroupingSeparator:groupingSeparator];

		NSString *relocalizedBadgeString = [numberFormatter stringFromNumber:@(badgeValue)];

		HBLogDebug(@"getBadgeValueType: 2. checking relocalized string: [%@] = [%@]", badgeString, relocalizedBadgeString);

		if ([badgeString isEqualToString:relocalizedBadgeString])
		{
			HBLogDebug(@"getBadgeValueType: kNumericBadge");
			return kNumericBadge;
		}
	}

	// unknown format, must be special

	HBLogDebug(@"getBadgeValueType: ran out of things to check... must be special");

	HBLogDebug(@"getBadgeValueType: kSpecialBadge");

	return kSpecialBadge;
}

- (CMBColorInfo *)getBadgeColorsForSpecialBadgeValue:(CMBIconInfo *)iconInfo
{
	NSInteger badgeType = [self getBadgeValueType:[iconInfo realBadgeNumberOrString]];

	if (kSpecialBadge != badgeType)
		return nil;

	CMBColorInfo *badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[[CMBPreferences sharedInstance] specialBadgesBackgroundColor] andForegroundColor:[[CMBPreferences sharedInstance] specialBadgesForegroundColor]];

	if (badgeColors)
		return badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:FALLBACK_SPECIAL_BADGES_BACKGROUND_COLOR andForegroundColor:FALLBACK_SPECIAL_BADGES_FOREGROUND_COLOR];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForApplication:(CMBIconInfo *)iconInfo
{
//	HBLogDebug(@"getBadgeColorsForApplication: scanning app: %@", iconInfo.nodeIdentifier);

	HBLogDebug(@"configuring for application icon: %@ (%@) with badge value: %@", iconInfo.nodeIdentifier, iconInfo.displayName, [iconInfo realBadgeNumberOrString]);

	CMBColorInfo *badgeColors;

	if ([[CMBPreferences sharedInstance] specialBadgesEnabled])
	{
		badgeColors = [self getBadgeColorsForSpecialBadgeValue:iconInfo];

		if (badgeColors)
			return badgeColors;
	}

	badgeColors = [self getBadgeColorsForApplicationIcon:iconInfo];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolderUsingMiniGrid:(CMBIconInfo *)iconInfo
{
//	[[CMBSexerUpper sharedInstance] saveImage:iconInfo.image withName:iconInfo.nodeIdentifier andPostfix:@"-folder"];

	CMBColorInfo *badgeColors = [self getPreferredAppBadgeForegroundColor:[self getPreferredAppBadgeColorsForIcon:iconInfo]];

	return badgeColors;
}

- (id)validBadgeNumberOrString:(CMBIconInfo *)iconInfo
{
	if (![[objc_getClass("SBIconController") sharedInstance] iconAllowsBadging:iconInfo.icon])
		return nil;

	id thisBadgeCount = [iconInfo realBadgeNumberOrString];

	if (!thisBadgeCount)
		return nil;

	NSInteger badgeType = [self getBadgeValueType:thisBadgeCount];

	if (kEmptyBadge == badgeType)
	{
		HBLogDebug(@"validBadgeNumberOrString: %@: badgeNumberOrString: %@  [INVALID]", iconInfo.nodeIdentifier, thisBadgeCount);
		return nil;
	}

	HBLogDebug(@"validBadgeNumberOrString: %@: badgeNumberOrString: %@", iconInfo.nodeIdentifier, thisBadgeCount);

	return thisBadgeCount;
}

- (CMBIconInfo *)getPositionalBadge:(CMBIconInfo *)iconInfo badgeType:(NSInteger)badgeType
{
	CMBIconInfo *targetIconInfo = nil;

	NSArray *lists = [[iconInfo.icon folder] lists];

	for (SBIconListModel *list in lists)
	{
		for (id thisIcon in [list icons])
		{
			CMBIconInfo *thisIconInfo = [[CMBIconInfo sharedInstance] getIconInfo:thisIcon];

			id thisBadgeCount = [self validBadgeNumberOrString:thisIconInfo];

			if (!thisBadgeCount)
				continue;

			switch (badgeType)
			{
				case kFBB_FirstBadge:
					return thisIconInfo;
					break;

				case kFBB_LastBadge:
					targetIconInfo = thisIconInfo;
					break;
			}
		}
	}

	return targetIconInfo;
}

- (CMBColorInfo *)getBadgeColorsForGenericIcon:(CMBIconInfo *)iconInfo
{
	CMBColorInfo *badgeColors;

	if (iconInfo.isApplication)
		badgeColors = [self getBadgeColorsForApplicationIcon:iconInfo];
	else
		badgeColors = [self getBadgeColorsForFolder:iconInfo];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolderUsingColorsFromPositionalBadge:(CMBIconInfo *)iconInfo badgeType:(NSInteger)badgeType
{
	CMBIconInfo *targetIconInfo = [self getPositionalBadge:iconInfo badgeType:badgeType];

	if (!targetIconInfo)
		return nil;

	CMBColorInfo *badgeColors;

	badgeColors = [self getBadgeColorsForGenericIcon:targetIconInfo];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolderUsingColorsFromNumberedBadge:(CMBIconInfo *)iconInfo badgeType:(NSInteger)badgeType
{
	CMBIconInfo *targetIconInfo = nil;
	NSInteger minBadgeValue = NSIntegerMax;
	NSInteger maxBadgeValue = 0;

	NSArray *lists = [[iconInfo.icon folder] lists];

	for (SBIconListModel *list in lists)
	{
		for (id thisIcon in [list icons])
		{
			CMBIconInfo *thisIconInfo = [[CMBIconInfo sharedInstance] getIconInfo:thisIcon];

			id thisBadgeCount = [self validBadgeNumberOrString:thisIconInfo];

			if (!thisBadgeCount || ![thisBadgeCount integerValue])
				continue;

			NSInteger thisBadgeNumber = [thisBadgeCount integerValue];

			switch (badgeType)
			{
				case kFBB_LowestBadge:
					if (thisBadgeNumber < minBadgeValue)
					{
						targetIconInfo = thisIconInfo;
						minBadgeValue = thisBadgeNumber;
					}
					break;

				case kFBB_HighestBadge:
					if (thisBadgeNumber > maxBadgeValue)
					{
						targetIconInfo = thisIconInfo;
						maxBadgeValue = thisBadgeNumber;
					}
					break;
			}
		}
	}

	if (!targetIconInfo)
		return nil;

	CMBColorInfo *badgeColors;

	badgeColors = [self getBadgeColorsForGenericIcon:targetIconInfo];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolderUsingColorsFromRandomBadge:(CMBIconInfo *)iconInfo preferCachedColors:(BOOL)preferCachedColors
{
	HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: begin", iconInfo.nodeIdentifier);

	CMBColorInfo *badgeColors = [cachedRandomFolderBadgeColors objectForKey:iconInfo.nodeIdentifier];

	if (badgeColors)
	{
		if (preferCachedColors)
		{
			HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: preferring cached colors", iconInfo.nodeIdentifier);
			return badgeColors;
		}

		[cachedRandomFolderBadgeColors removeObjectForKey:iconInfo.nodeIdentifier];

		CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: examining cached colors; elapsed: %f", iconInfo.nodeIdentifier, now - badgeColors.now);

		if ((now - badgeColors.now) < 0.5)
		{
			HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: found recent colors", iconInfo.nodeIdentifier);

			badgeColors.now = CFAbsoluteTimeGetCurrent();
			[cachedRandomFolderBadgeColors setObject:badgeColors forKey:iconInfo.nodeIdentifier];

			return badgeColors;
		}

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: found stale colors", iconInfo.nodeIdentifier);
	}

	// choose new icon if no cached or stale icon
	CMBIconInfo *targetIconInfo = nil;

	NSMutableArray *badgedIcons = [[NSMutableArray alloc] init];

	NSArray *lists = [[iconInfo.icon folder] lists];

	for (SBIconListModel *list in lists)
	{
		for (id thisIcon in [list icons])
		{
			CMBIconInfo *thisIconInfo = [[CMBIconInfo sharedInstance] getIconInfo:thisIcon];

			id thisBadgeCount = [self validBadgeNumberOrString:thisIconInfo];

			if (!thisBadgeCount)
				continue;

			[badgedIcons addObject:thisIconInfo];
		}
	}

	if ([badgedIcons count] > 0)
	{
		targetIconInfo = badgedIcons[arc4random_uniform([badgedIcons count])];

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: chose random icon: %@", iconInfo.nodeIdentifier, targetIconInfo.nodeIdentifier);
	}

	if (!targetIconInfo)
		return nil;

	badgeColors = [self getBadgeColorsForGenericIcon:targetIconInfo];

	// add new entry
	badgeColors.now = CFAbsoluteTimeGetCurrent();
	[cachedRandomFolderBadgeColors setObject:badgeColors forKey:iconInfo.nodeIdentifier];

	HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: %@: using icon: %@  with badge value: %@",
		iconInfo.nodeIdentifier, targetIconInfo.nodeIdentifier, [targetIconInfo realBadgeNumberOrString]);

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolderUsingAverageColorFromBadges:(CMBIconInfo *)iconInfo averageType:(NSInteger)averageType
{
	CGFloat r, g, b, a;

	CGFloat fgr = 0.0;
	CGFloat fgg = 0.0;
	CGFloat fgb = 0.0;
	CGFloat bgr = 0.0;
	CGFloat bgg = 0.0;
	CGFloat bgb = 0.0;

	NSInteger total = 0;
	NSInteger weightFactor;

	NSArray *lists = [[iconInfo.icon folder] lists];

	for (SBIconListModel *list in lists)
	{
		for (id thisIcon in [list icons])
		{
			CMBIconInfo *thisIconInfo = [[CMBIconInfo sharedInstance] getIconInfo:thisIcon];

			id thisBadgeCount = [self validBadgeNumberOrString:thisIconInfo];

			if (!thisBadgeCount || ![thisBadgeCount integerValue])
				continue;

			NSInteger thisBadgeNumber = [thisBadgeCount integerValue];

			weightFactor = (kFBB_WeightedAverageColor == averageType) ? thisBadgeNumber : 1;

			CMBColorInfo *thisBadgeColors = nil;

			thisBadgeColors = [self getBadgeColorsForGenericIcon:thisIconInfo];

			[thisBadgeColors.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
			bgr += r * weightFactor;
			bgg += g * weightFactor;
			bgb += b * weightFactor;

			[thisBadgeColors.foregroundColor getRed:&r green:&g blue:&b alpha:&a];
			fgr += r * weightFactor;
			fgg += g * weightFactor;
			fgb += b * weightFactor;

			total += weightFactor;
		}
	}

	if (0 == total)
		return nil;

	UIColor *backgroundColor = [UIColor colorWithRed:bgr/total green:bgg/total blue:bgb/total alpha:1.0f];

//	UIColor *foregroundColor = [UIColor colorWithRed:fgr/total green:fgg/total blue:fgb/total alpha:1.0f];
//	UIColor *foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:nil];

	return badgeColors;
}

- (CMBColorInfo *)getPreferredFolderBadgeForegroundColor:(CMBColorInfo *)currentColors
{
	UIColor *backgroundColor = currentColors.backgroundColor;
	UIColor *foregroundColor = currentColors.foregroundColor;

	switch ([[CMBPreferences sharedInstance] folderBadgeForegroundType])
	{
		case kFBF_FixedColor:
			foregroundColor = [[CMBPreferences sharedInstance] folderBadgeForegroundColor];
			break;

		case kFBF_ByBrightness:
			backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
			foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			break;

		case kFBF_ByBadgeElseFixedColor:
			if (!foregroundColor)
			{
				foregroundColor = [[CMBPreferences sharedInstance] folderBadgeForegroundColor];
			}
			break;

		case kFBF_ByBadgeElseBrightness:
			if (!foregroundColor)
			{
				backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
				foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			}
			break;
	}

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:foregroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getPreferredFolderBadgeColors:(CMBIconInfo *)iconInfo
{
	CMBColorInfo *badgeColors = nil;

	NSInteger folderBadgeBackgroundType = [[CMBPreferences sharedInstance] folderBadgeBackgroundType];

	switch (folderBadgeBackgroundType)
	{
		case kFBB_FixedColor:
			badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[[CMBPreferences sharedInstance] folderBadgeBackgroundColor] andForegroundColor:nil];
			break;

		case kFBB_LowestBadge:
		case kFBB_HighestBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromNumberedBadge:iconInfo badgeType:folderBadgeBackgroundType];
			break;

		case kFBB_RandomBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromRandomBadge:iconInfo preferCachedColors:NO];
			break;

		case kFBB_FirstBadge:
		case kFBB_LastBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromPositionalBadge:iconInfo badgeType:folderBadgeBackgroundType];
			break;

		case kFBB_AverageColor:
		case kFBB_WeightedAverageColor:
			badgeColors = [self getBadgeColorsForFolderUsingAverageColorFromBadges:iconInfo averageType:folderBadgeBackgroundType];
			break;

		case kFBB_FolderMinigrid:
			badgeColors = [self getBadgeColorsForFolderUsingMiniGrid:iconInfo];
			break;

		case kFBB_RandomColor:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingRandom];
			break;
	}

	if (badgeColors)
		return badgeColors;

	badgeColors = [self getBadgeColorsForFolderUsingColorsFromPositionalBadge:iconInfo badgeType:kFBB_FirstBadge];

	if (badgeColors)
		return badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithStockColors];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolder:(CMBIconInfo *)iconInfo
{
	HBLogDebug(@"configuring for folder icon: %@ (%@) with badge value: %@", iconInfo.nodeIdentifier, iconInfo.displayName, [iconInfo realBadgeNumberOrString]);

	CMBColorInfo *badgeColors;

	if ([[CMBPreferences sharedInstance] specialBadgesEnabled])
	{
		badgeColors = [self getBadgeColorsForSpecialBadgeValue:iconInfo];

		if (badgeColors)
			return badgeColors;
	}

	badgeColors = [self getPreferredFolderBadgeForegroundColor:[self getPreferredFolderBadgeColors:iconInfo]];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForUnknown
{
	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithStockColors];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForDisabled
{
	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithStockColors];

	return badgeColors;
}

- (CMBColorInfo *)getBackgroundForegroundColorsForIcon:(id)icon
{
	CMBColorInfo *badgeColors = nil;

	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		badgeColors = [self getBadgeColorsForDisabled];
		return badgeColors;
	}

	CMBIconInfo *iconInfo = [[CMBIconInfo sharedInstance] getIconInfo:icon];

	if (!iconInfo)
	{
		badgeColors = [self getBadgeColorsForUnknown];
		return badgeColors;
	}

	if (iconInfo.isApplication)
		badgeColors = [self getBadgeColorsForApplication:iconInfo];
	else
		badgeColors = [self getBadgeColorsForFolder:iconInfo];

	if (badgeColors)
		return badgeColors;

	badgeColors = [self getBadgeColorsForUnknown];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon
{
	CMBColorInfo *badgeColors;

	badgeColors = [self getBackgroundForegroundColorsForIcon:icon];
	badgeColors.borderColor = [self getPreferredBorderColor:badgeColors];

//	badgeColors = [self adjustColorsForDisplay:badgeColors];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForApplicationIdentifier:(NSString *)applicationBundleID
{
	SBIcon *icon = [[[objc_getClass("SBIconController") sharedInstance] model] applicationIconForBundleIdentifier:applicationBundleID];

	return [self getBadgeColorsForIcon:icon];
}

- (void)redrawBadges:(NSString *)applicationBundleID
{
	for (SBLeafIcon *icon in [[[objc_getClass("SBIconController") sharedInstance] model] leafIcons])
	{
		if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
			continue;

		if (applicationBundleID && ![applicationBundleID isEqualToString:[icon applicationBundleID]])
			continue;

		id badgeNumberOrString = [icon badgeNumberOrString];

		if (!badgeNumberOrString)
			continue;

		HBLogDebug(@"redrawBadges: redrawing: %@", [icon applicationBundleID]);

//		[icon noteBadgeDidChange];
		[icon setBadge:nil];
		[icon setBadge:badgeNumberOrString];
	}
}

- (void)refreshBadgesForAllApplications
{
	HBLogDebug(@"refreshBadgesForAllApplications: refreshing all badges");

	[cachedRandomFolderBadgeColors removeAllObjects];

	[cachedAppBadgeColors removeAllObjects];

	[self redrawBadges:nil];
}

- (void)refreshBadgesForApplication:(NSString *)applicationBundleID
{
	HBLogDebug(@"refreshBadgesForApplication: refreshing badges for app: %@", applicationBundleID);

	[cachedRandomFolderBadgeColors removeAllObjects];

	[cachedAppBadgeColors removeObjectForKey:applicationBundleID];

	[self redrawBadges:applicationBundleID];
}

- (void)refreshBadges:(NSString *)applicationBundleID
{
	if (applicationBundleID)
		[self refreshBadgesForApplication:applicationBundleID];
	else
		[self refreshBadgesForAllApplications];
}

- (void)reloadTheme
{
	[self refreshBadgesForAllApplications];
}

- (CGFloat)getScaledCornerRadius:(CGFloat)fullCornerRadius
{
	CGFloat cornerRoundnessScale = (CGFloat)[[CMBPreferences sharedInstance] badgeCornerRoundnessScale] / 100.0;

	// scale corner radius, rounding to nearest half
	CGFloat cornerRadius = round(fullCornerRadius * cornerRoundnessScale * 2.0) / 2.0;

	HBLogDebug(@"getScaledCornerRadius: fullCornerRadius: %0.2f  scale: %0.3f => cornerRadius: %0.2f", fullCornerRadius, cornerRoundnessScale, cornerRadius);

	return cornerRadius;
}

@end

// vim:ft=objc
