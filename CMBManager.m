#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CMBManager.h"
#import "CMBPreferences.h"
#import "CMBSexerUpper.h"
#import "LEColorPicker.h"
#import "CCColorCube.h"

@implementation CMBManager

- (CMBManager *)init
{
	self = [super init];

	if (self)
	{
		cachedAppBadgeColors = [[NSMutableDictionary alloc] init];
		cachedRandomFolderBadgeColors = [[NSMutableDictionary alloc] init];
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
		backgroundColor = fallbackAppBadgeBackgroundColor;

	switch ([[CMBPreferences sharedInstance] appBadgeForegroundType])
	{
		case kABFFixedColor:
			foregroundColor = [[CMBPreferences sharedInstance] appBadgeForegroundColor];
			break;

		case kABFBrightness:
			backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
			foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			break;

		case kABFAlgorithmElseFixedColor:
			if (!foregroundColor)
			{
				foregroundColor = [[CMBPreferences sharedInstance] appBadgeForegroundColor];
			}
			break;

		case kABFAlgorithmElseBrightness:
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

	CMBColorInfo *badgeColors = nil;

	switch ([[CMBPreferences sharedInstance] appBadgeBackgroundType])
	{
		case kABBFixedColor:
			badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[[CMBPreferences sharedInstance] appBadgeBackgroundColor] andForegroundColor:nil];
			break;

		case kABBCCColorCube:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingCCColorCube:iconImage];
			break;

		case kABBLEColorPicker:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingLEColorPicker:iconImage];
			break;

		case kABBBoover:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingBooverAlgorithm:iconImage];
			break;

		case kABBColorBadges:
			badgeColors = [[CMBSexerUpper sharedInstance] getColorsUsingColorBadges:iconImage];
			break;
	}

	if (badgeColors)
		return badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:fallbackAppBadgeBackgroundColor andForegroundColor:fallbackAppBadgeForegroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForApplicationIcon:(CMBIconInfo *)iconInfo
{
	CMBColorInfo *badgeColors = [cachedAppBadgeColors objectForKey:iconInfo.nodeIdentifier];

	if (badgeColors)
		return badgeColors;

	HBLogDebug(@"getBadgeColorsForApplicationIcon: scanning app: %@",iconInfo.nodeIdentifier);

//	[[CMBSexerUpper sharedInstance] saveImage:iconInfo.image withName:iconInfo.nodeIdentifier andPostfix:@"-masked"];
//	[[CMBSexerUpper sharedInstance] saveImage:iconInfo.unmaskedImage withName:iconInfo.nodeIdentifier andPostfix:@"-unmasked"];

	badgeColors = [self getPreferredAppBadgeForegroundColor:[self getPreferredAppBadgeColorsForIcon:iconInfo]];

	[cachedAppBadgeColors setObject:badgeColors forKey:iconInfo.nodeIdentifier];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForSpecialBadgeValue:(CMBIconInfo *)iconInfo
{
	id badgeCount = [iconInfo.icon badgeNumberOrString];

	if (!badgeCount)
		return nil;

	if (![badgeCount isKindOfClass:[NSString class]])
		return nil;

	NSString *badgeString = (NSString *)badgeCount;

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:fallbackSpecialBadgeBackgroundColor andForegroundColor:fallbackSpecialBadgeForegroundColor];

	// only want non-negative integers
	NSScanner *scanner = [NSScanner scannerWithString:badgeString];
	NSInteger badgeValue;

	BOOL isNumeric = [scanner scanInteger:&badgeValue] && [scanner isAtEnd];

	if ((!isNumeric) || (badgeValue < 0))
		return badgeColors;

	return nil;
}

- (CMBColorInfo *)getBadgeColorsForApplication:(CMBIconInfo *)iconInfo
{
//	HBLogDebug(@"getBadgeColorsForApplication: scanning app: %@",iconInfo.nodeIdentifier);

	HBLogDebug(@"configuring for application icon: %@  with badge value: %@",iconInfo.nodeIdentifier,[iconInfo.icon badgeNumberOrString]);

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

	id thisBadgeCount = [iconInfo.icon badgeNumberOrString];

	if (!thisBadgeCount)
		return nil;

	if ([thisBadgeCount isKindOfClass:[NSString class]])
	{
		NSString *thisBadgeString = (NSString *)thisBadgeCount;

		if ([thisBadgeString isEqualToString:@""])
		{
//			HBLogDebug(@"validBadgeNumberOrString: thisBadgeCount was empty");
			return nil;
		}
	}

	HBLogDebug(@"validBadgeNumberOrString: %@: badgeNumberOrString: %@",iconInfo.nodeIdentifier,thisBadgeCount);

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
				case kFBBFirstBadge:
					return thisIconInfo;
					break;

				case kFBBLastBadge:
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
				case kFBBLowestBadge:
					if (thisBadgeNumber < minBadgeValue)
					{
						targetIconInfo = thisIconInfo;
						minBadgeValue = thisBadgeNumber;
					}
					break;

				case kFBBHighestBadge:
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

- (CMBColorInfo *)getBadgeColorsForFolderUsingColorsFromRandomBadge:(CMBIconInfo *)iconInfo
{
	id uniqueFolderID = [NSString stringWithFormat:@"%p",[iconInfo.icon folder]];

	HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: begin",uniqueFolderID,iconInfo.nodeIdentifier);

	CMBColorInfo *badgeColors = [cachedRandomFolderBadgeColors objectForKey:uniqueFolderID];

	if (badgeColors)
	{
		[cachedRandomFolderBadgeColors removeObjectForKey:uniqueFolderID];

		CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: examining cached colors; elapsed: %f",uniqueFolderID,iconInfo.nodeIdentifier,now-badgeColors.now);

		if ((now - badgeColors.now) < 0.5)
		{
			HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: found recent colors",uniqueFolderID,iconInfo.nodeIdentifier);

			badgeColors.now = CFAbsoluteTimeGetCurrent();
			[cachedRandomFolderBadgeColors setObject:badgeColors forKey:uniqueFolderID];

			return badgeColors;
		}

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: found stale colors",uniqueFolderID,iconInfo.nodeIdentifier);
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

		HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: chose random icon: %@",uniqueFolderID,iconInfo.nodeIdentifier,targetIconInfo.nodeIdentifier);
	}

	if (!targetIconInfo)
		return nil;

	badgeColors = [self getBadgeColorsForGenericIcon:targetIconInfo];

	// add new entry
	badgeColors.now = CFAbsoluteTimeGetCurrent();
	[cachedRandomFolderBadgeColors setObject:badgeColors forKey:uniqueFolderID];

	HBLogDebug(@"getBadgeColorsForFolderUsingColorsFromRandomBadge: [%@] %@: using icon: %@  with badge value: %@"
		,uniqueFolderID,iconInfo.nodeIdentifier,targetIconInfo.nodeIdentifier,[targetIconInfo.icon badgeNumberOrString]);

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

			weightFactor = (kFBBWeightedAverageColor == averageType) ? thisBadgeNumber : 1;

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
		case kFBFFixedColor:
			foregroundColor = [[CMBPreferences sharedInstance] folderBadgeForegroundColor];
			break;

		case kFBFBrightness:
			backgroundColor = [[CMBSexerUpper sharedInstance] adjustBackgroundColorByPreference:backgroundColor];
			foregroundColor = [[CMBSexerUpper sharedInstance] getForegroundColorByBrightnessThreshold:backgroundColor];
			break;

		case kFBFBadgeElseFixedColor:
			if (!foregroundColor)
			{
				foregroundColor = [[CMBPreferences sharedInstance] folderBadgeForegroundColor];
			}
			break;

		case kFBFBadgeElseBrightness:
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
		case kFBBFixedColor:
			badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[[CMBPreferences sharedInstance] folderBadgeBackgroundColor] andForegroundColor:nil];
			break;

		case kFBBLowestBadge:
		case kFBBHighestBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromNumberedBadge:iconInfo badgeType:folderBadgeBackgroundType];
			break;

		case kFBBRandomBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromRandomBadge:iconInfo];
			break;

		case kFBBFirstBadge:
		case kFBBLastBadge:
			badgeColors = [self getBadgeColorsForFolderUsingColorsFromPositionalBadge:iconInfo badgeType:folderBadgeBackgroundType];
			break;

		case kFBBAverageColor:
		case kFBBWeightedAverageColor:
			badgeColors = [self getBadgeColorsForFolderUsingAverageColorFromBadges:iconInfo averageType:folderBadgeBackgroundType];
			break;

		case kFBBFolderMinigrid:
			badgeColors = [self getBadgeColorsForFolderUsingMiniGrid:iconInfo];
			break;
	}

	if (badgeColors)
		return badgeColors;

	badgeColors = [self getBadgeColorsForFolderUsingColorsFromPositionalBadge:iconInfo badgeType:kFBBFirstBadge];

	if (badgeColors)
		return badgeColors;

	badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:fallbackFolderBadgeBackgroundColor andForegroundColor:fallbackFolderBadgeForegroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForFolder:(CMBIconInfo *)iconInfo
{
	HBLogDebug(@"configuring for folder icon: %@  with badge value: %@",iconInfo.nodeIdentifier,[iconInfo.icon badgeNumberOrString]);

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
	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:fallbackUnknownBadgeBackgroundColor andForegroundColor:fallbackUnknownBadgeForegroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForDisabled
{
	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:fallbackDisabledBadgeBackgroundColor andForegroundColor:fallbackDisabledBadgeForegroundColor];

	return badgeColors;
}

- (CMBColorInfo *)getBadgeColorsForIcon:(id)icon
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

- (void)clearCachedColors
{
	[cachedAppBadgeColors removeAllObjects];
	[cachedRandomFolderBadgeColors removeAllObjects];
}

- (void)clearCachedColorsForApplication:(NSString *)applicationBundleID
{
	HBLogDebug(@"clearCachedColorsForApplication: clearing colors for app: %@",applicationBundleID);
	[cachedAppBadgeColors removeObjectForKey:applicationBundleID];
}

@end

// vim:ft=objc
