#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CMBSexerUpper.h"
#import "CMBPreferences.h"
#import "ColorBadges.h"
#import "LEColorPicker.h"
#import "CCColorCube.h"
#import "Colours.h"

#define COLORBADGESCLASS objc_getClass("ColorBadges")

@implementation CMBSexerUpper

- (CMBSexerUpper *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/*
- (void)dealloc
{
	[super dealloc];
}
*/

+ (CMBSexerUpper *)sharedInstance
{
	static CMBSexerUpper *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[CMBSexerUpper alloc] init];
		// Do any other initialisation stuff here
	});

	return sharedInstance;
}

- (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color
{
	if (!image)
	{
		HBLogDebug(@"colorizeImage: called with nil image and color: %@",color);
		return image;
	}

	if (!color)
	{
		HBLogDebug(@"colorizeImage: called with nil color");
		return image;
	}

	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[color setFill];
	CGContextTranslateCTM(context, 0, image.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
	CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
	UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return colorizedImage;
}

- (CGFloat)getBrightnessForColorUsingRGB:(UIColor *)color
{
	CGColorRef colorref = [color CGColor];

	int numComponents = CGColorGetNumberOfComponents(colorref);
	const CGFloat *components = CGColorGetComponents(colorref);

	CGFloat brightness = 0;

	if (2 == numComponents)
		brightness = ((components[0] * 299) + (components[0] * 587) + (components[0] * 114)) / 1000;
	else if (4 == numComponents)
		brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000;

	return brightness;
}

- (CGFloat)getNormalizedBrightnessUsingCIELAB:(UIColor *)backgroundColor
{
	NSDictionary *colorDict = [backgroundColor CIE_LabDictionary];
	NSNumber *L = colorDict[kColoursCIE_L];
	CGFloat normalizedBrightness = 10 * [L doubleValue];

//	HBLogDebug(@"getNormalizedBrightnessUsingCIELAB: L = %0.2f --> n = %0.2f",[L doubleValue],normalizedBrightness);

	return normalizedBrightness;
}

- (CGFloat)getNormalizedBrightnessUsingRGB:(UIColor *)backgroundColor
{
	CGFloat backgroundColorBrightness = [self getBrightnessForColorUsingRGB:backgroundColor];
	CGFloat normalizedBrightness = backgroundColorBrightness * 1000;

//	HBLogDebug(@"getNormalizedBrightnessUsingRGB: b = %0.2f --> n = %0.2f",backgroundColorBrightness,normalizedBrightness);

	return normalizedBrightness;
}

- (CGFloat)getNormalizedBrightness:(UIColor *)color
{
	CGFloat normalizedBrightness = 0.0;

	switch ([[CMBPreferences sharedInstance] colorSpaceType])
	{
		case kColorSpaceRGB:
			return [self getNormalizedBrightnessUsingRGB:color];
			break;

		case kColorSpaceCIELAB:
			return [self getNormalizedBrightnessUsingCIELAB:color];
			break;
	}

	return normalizedBrightness;
}

- (UIColor *)getForegroundColorByBrightnessThreshold:(UIColor *)backgroundColor
{
	CGFloat normalizedBrightness = [self getNormalizedBrightness:backgroundColor];

	NSInteger brightnessThreshold = [[CMBPreferences sharedInstance] brightnessThreshold];

/*
	CGFloat whiteDistance = [backgroundColor distanceFromColor:realWhiteColor type:ColorDistanceCIE2000];
	CGFloat blackDistance = [backgroundColor distanceFromColor:realBlackColor type:ColorDistanceCIE2000];

	HBLogDebug(@"getForegroundColorByBrightnessThreshold: n = %0.2f  pref = %ld --> %@ / wD = %0.2f bD = %0.2f --> %@"
				,normalizedBrightness
				,(long)brightnessThreshold
				,(normalizedBrightness > brightnessThreshold) ? @"black" : @"white"
				,whiteDistance
				,blackDistance
				,(blackDistance > whiteDistance) ? @"black" : @"white"
			);
*/

	if (normalizedBrightness > brightnessThreshold)
		return realBlackColor;

	return realWhiteColor;
}

- (UIColor *)shadeColorUsingRGB:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	CGFloat r, g, b, a;

	CGFloat originalBrightness = [self getNormalizedBrightnessUsingRGB:color];

	[color getRed:&r green:&g blue:&b alpha:&a];

	CGFloat x = 1.0 - (targetBrightness / originalBrightness);

	UIColor *shadedColor = [UIColor colorWithRed:r*(1.0-x) green:g*(1.0-x) blue:b*(1.0-x) alpha:a];

#ifdef DEBUG
	CGFloat shadedBrightness = [self getNormalizedBrightnessUsingRGB:shadedColor];

	HBLogDebug(@"shadeColorUsingRGB: orig: %0.5f => target: %0.5f ---> actual: %0.5f",originalBrightness,targetBrightness,shadedBrightness);
#endif

	return shadedColor;
}

- (UIColor *)tintColorUsingRGB:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	CGFloat r, g, b, a;

	CGFloat originalBrightness = [self getNormalizedBrightnessUsingRGB:color];

	[color getRed:&r green:&g blue:&b alpha:&a];

	CGFloat x = (targetBrightness - originalBrightness) / (1000.0 - originalBrightness);

	UIColor *tintedColor = [UIColor colorWithRed:r+x*(1.0-r) green:g+x*(1.0-g) blue:b+x*(1.0-b) alpha:a];

#ifdef DEBUG
	CGFloat tintedBrightness = [self getNormalizedBrightnessUsingRGB:tintedColor];

	HBLogDebug(@"tintColorUsingRGB: orig: %0.5f => target: %0.5f ---> actual: %0.5f",originalBrightness,targetBrightness,tintedBrightness);
#endif

	return tintedColor;
}

- (UIColor *)shadeColorUsingCIELAB:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	NSDictionary *colorDict = [color CIE_LabDictionary];

	NSMutableDictionary *newColorDict = [colorDict mutableCopy];
	UIColor *shadedColor;

	CGFloat targetL = targetBrightness / 10.0;

	// create new color with target L
	newColorDict[kColoursCIE_L] = @(targetL);
	shadedColor = [UIColor colorFromCIE_LabDictionary:newColorDict];

	// read back color and check L
	NSDictionary *shadedColorDict = [shadedColor CIE_LabDictionary];
	NSNumber *shadedL = shadedColorDict[kColoursCIE_L];
	CGFloat adjustedL = targetL;

#ifdef DEBUG
	NSNumber *L = colorDict[kColoursCIE_L];

	HBLogDebug(@"shadeColorUsingCIELAB: L: orig: %0.5f => target: %0.5f ---> actual: %0.5f",[L doubleValue],targetL,[shadedL doubleValue]);
#endif

	// if L still too high, keep reducing it slightly
	while (([shadedL doubleValue] >= targetL) && (adjustedL > 0.0))
	{
		adjustedL -= 0.1;

		newColorDict[kColoursCIE_L] = @(adjustedL);
		shadedColor = [UIColor colorFromCIE_LabDictionary:newColorDict];

		shadedColorDict = [shadedColor CIE_LabDictionary];
		shadedL = shadedColorDict[kColoursCIE_L];

		HBLogDebug(@"shadeColorUsingCIELAB: L: target: %0.5f => adjusted: %0.5f ---> actual: %0.5f",targetL,adjustedL,[shadedL doubleValue]);
	}

	return shadedColor;
}

- (UIColor *)tintColorUsingCIELAB:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	NSDictionary *colorDict = [color CIE_LabDictionary];

	NSMutableDictionary *newColorDict = [colorDict mutableCopy];
	UIColor *tintedColor;

	CGFloat targetL = targetBrightness / 10.0;

	// create new color with target L
	newColorDict[kColoursCIE_L] = @(targetL);
	tintedColor = [UIColor colorFromCIE_LabDictionary:newColorDict];

	// read back color and check L
	NSDictionary *tintedColorDict = [tintedColor CIE_LabDictionary];
	NSNumber *tintedL = tintedColorDict[kColoursCIE_L];
	CGFloat adjustedL = targetL;

#ifdef DEBUG
	NSNumber *L = colorDict[kColoursCIE_L];

	HBLogDebug(@"tintColorUsingCIELAB: L: orig: %0.5f => target: %0.5f ---> actual: %0.5f",[L doubleValue],targetL,[tintedL doubleValue]);
#endif

	// if L still too low, keep increasing it slightly
	while (([tintedL doubleValue] <= targetL) && (adjustedL < 100.0))
	{
		adjustedL += 0.1;

		newColorDict[kColoursCIE_L] = @(adjustedL);
		tintedColor = [UIColor colorFromCIE_LabDictionary:newColorDict];

		tintedColorDict = [tintedColor CIE_LabDictionary];
		tintedL = tintedColorDict[kColoursCIE_L];

		HBLogDebug(@"tintColorUsingCIELAB: L: target: %0.5f => adjusted: %0.5f ---> actual: %0.5f",targetL,adjustedL,[tintedL doubleValue]);
	}

	return tintedColor;
}

- (UIColor *)shadeColor:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	UIColor *shadedColor = nil;

	switch ([[CMBPreferences sharedInstance] colorSpaceType])
	{
		case kColorSpaceRGB:
			shadedColor = [self shadeColorUsingRGB:color toNormalizedBrightness:targetBrightness];
			break;

		case kColorSpaceCIELAB:
			shadedColor = [self shadeColorUsingCIELAB:color toNormalizedBrightness:targetBrightness];
			break;
	}

	if (!shadedColor)
		return color;

	return shadedColor;
}

- (UIColor *)tintColor:(UIColor *)color toNormalizedBrightness:(CGFloat)targetBrightness
{
	UIColor *tintedColor = nil;

	switch ([[CMBPreferences sharedInstance] colorSpaceType])
	{
		case kColorSpaceRGB:
			tintedColor = [self tintColorUsingRGB:color toNormalizedBrightness:targetBrightness];
			break;

		case kColorSpaceCIELAB:
			tintedColor = [self tintColorUsingCIELAB:color toNormalizedBrightness:targetBrightness];
			break;
	}

	if (!tintedColor)
		return color;

	return tintedColor;
}

- (UIColor *)shadeColorToBrightnessThreshold:(UIColor *)color
{
	CGFloat normalizedBrightness = [self getNormalizedBrightness:color];

	NSInteger brightnessThreshold = [[CMBPreferences sharedInstance] brightnessThreshold];

//	HBLogDebug(@"shadeColorToBrightnessThreshold: n = %0.2f  pref = %lu",normalizedBrightness,(unsigned long)brightnessThreshold);

	if (normalizedBrightness > brightnessThreshold)
		return [self shadeColor:color toNormalizedBrightness:brightnessThreshold - 1.0];

	return color;
}

- (UIColor *)tintColorToBrightnessThreshold:(UIColor *)color
{
	CGFloat normalizedBrightness = [self getNormalizedBrightness:color];

	NSInteger brightnessThreshold = [[CMBPreferences sharedInstance] brightnessThreshold];

//	HBLogDebug(@"tintColorToBrightnessThreshold: n = %0.2f  pref = %lu",normalizedBrightness,(unsigned long)brightnessThreshold);

	if (normalizedBrightness < brightnessThreshold)
		return [self tintColor:color toNormalizedBrightness:brightnessThreshold + 1.0];

	return color;
}

- (UIColor *)adjustBackgroundColorByPreference:(UIColor *)color
{
	switch ([[CMBPreferences sharedInstance] badgeColorAdjustmentType])
	{
		case kNoAdjustment:
			return color;
			break;

		case kShadeForWhiteText:
			return [self shadeColorToBrightnessThreshold:color];
			break;

		case kTintForBlackText:
			return [self tintColorToBrightnessThreshold:color];
			break;
	}

	return color;
}

- (UIColor *)shadeColorByBrightnessFactor:(UIColor *)color factor:(double)factor
{
	CGFloat normalizedBrightness = [self getNormalizedBrightness:color];

	CGFloat targetBrightness = fmaxf(normalizedBrightness * factor,1.0);

	return [self shadeColor:color toNormalizedBrightness:targetBrightness];
}

- (UIColor *)tintColorByBrightnessFactor:(UIColor *)color factor:(double)factor
{
	CGFloat normalizedBrightness = [self getNormalizedBrightness:color];

	CGFloat targetBrightness = fminf(normalizedBrightness * factor,NORMALIZED_BRIGHTNESS_SCALE - 1.0);

	return [self tintColor:color toNormalizedBrightness:targetBrightness];
}

- (UIColor *)adjustBorderColorByPreference:(UIColor *)color
{
//	double percent = (double)[[CMBPreferences sharedInstance] badgeBorderShadeTintPercentage] / 100.0;
	double percent = 30.0 / 100.0;

	switch ([[CMBPreferences sharedInstance] badgeBorderType])
	{
		case kBB_ByShadedBadgeBackgroundColor:
			return [self shadeColorByBrightnessFactor:color factor:1.0 - percent];
			break;

		case kBB_ByTintedBadgeBackgroundColor:
			return [self tintColorByBrightnessFactor:color factor:1.0 + percent];
			break;
	}

	return color;
}

/*
- (void)saveImage:(UIImage *)image withName:(NSString *)name andPostfix:(NSString *)postfix
{
	return;

	static NSInteger imageCount = 1;

	NSString *pngFile = [NSString stringWithFormat:@"/tmp/cmb/%@-%@-%03ld.png",name,postfix,(long)imageCount];

	HBLogDebug(@"saving image to: %@",pngFile);

	[UIImagePNGRepresentation(image) writeToFile:pngFile atomically:YES];

	imageCount++;
}

- (UIImage *)getSubImageFrom:(UIImage *)img withRect:(CGRect)rect
{
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// translated rectangle for drawing sub image
	CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);

	// clip to the bounds of the image context
	// not strictly necessary as it will get clipped anyway?
	CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

	// draw image
	[img drawInRect:drawRect];

	// grab image
	UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return subImage;
}

- (UIImage *)cropMiddleOfImage:(UIImage *)image withFactor:(CGFloat)factor forApp:(NSString *)app
{
//	[self saveImage:image withName:app andPostfix:@""];

	// crop image
	CGFloat cropSize = factor * fminf(image.size.width,image.size.height);
	CGFloat edgeSize = (fminf(image.size.width,image.size.height) - cropSize) / 2.0f;

	CGRect middle = CGRectMake(edgeSize,edgeSize,cropSize,cropSize);
	UIImage *croppedImage = [self getSubImageFrom:image withRect:middle];

//	[self saveImage:croppedImage withName:app andPostfix:@"-cropped"];

	return croppedImage;
}
*/

- (CMBColorInfo *)swapColorsIfBackgroundIsBright:(CMBColorInfo *)colors
{
	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:colors.backgroundColor andForegroundColor:colors.foregroundColor];

	NSDictionary *backgroundColorDict = [colors.backgroundColor CIE_LabDictionary];
	NSNumber *backgroundL = backgroundColorDict[kColoursCIE_L];

	NSDictionary *foregroundColorDict = [colors.foregroundColor CIE_LabDictionary];
	NSNumber *foregroundL = foregroundColorDict[kColoursCIE_L];

	double foregroundBrightness = [foregroundL doubleValue];
	double backgroundBrightness = [backgroundL doubleValue];

//	HBLogDebug(@"swapColorsIfBackgroundIsBright: backgroundL = %0.2f  foregroundL = %0.2f",backgroundBrightness,foregroundBrightness);

	if ((backgroundBrightness > foregroundBrightness) && (backgroundBrightness > 80) && (foregroundBrightness > 10))
	{
		badgeColors.backgroundColor = colors.foregroundColor;
		badgeColors.foregroundColor = colors.backgroundColor;
	}

	return badgeColors;
}

- (CMBColorInfo *)getColorsUsingLEColorPicker:(UIImage *)image
{
	LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
	LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:image];

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:[colorScheme backgroundColor] andForegroundColor:[colorScheme primaryTextColor]];

	// FIXME: testing
	badgeColors = [self swapColorsIfBackgroundIsBright:badgeColors];

//	[colorPicker release];

	return badgeColors;
}

- (BOOL)colorSeemsGrey:(UIColor *)color
{
	CGFloat r, g, b, a;
	CGFloat steps = 255.0;
	NSInteger epsilon = 25;

	[color getRed:&r green:&g blue:&b alpha:&a];

	NSInteger red = (NSInteger)(steps * r);
	NSInteger green = (NSInteger)(steps * g);
	NSInteger blue = (NSInteger)(steps * b);

	if ((ABS(red-green) <= epsilon) && (ABS(green-blue) <= epsilon) && (ABS(blue-red) <= epsilon))
		return YES;

	return NO;
}

- (CMBColorInfo *)getColorsUsingCCColorCube:(UIImage *)image
{
	CCColorCube *colorCube = [[CCColorCube alloc] init];

	NSArray *backgroundColors;
	NSArray *foregroundColors;

	backgroundColors = [colorCube extractColorsFromImage:image flags:CCAvoidWhite|CCAvoidBlack];
	// FIXME: testing
	foregroundColors = [colorCube extractColorsFromImage:image flags:CCAvoidWhite|CCAvoidBlack];
//	foregroundColors = [colorCube extractColorsFromImage:image flags:0];

	if (0 == [backgroundColors count])
	{
		// hmm
		HBLogDebug(@"getColorsUsingCCColorCube: no colors; just avoiding white");
		backgroundColors = [colorCube extractColorsFromImage:image flags:CCAvoidWhite];
	}

	if (0 == [backgroundColors count])
	{
		// hmm
		HBLogDebug(@"getColorsUsingCCColorCube: no colors; just avoiding black");
		backgroundColors = [colorCube extractColorsFromImage:image flags:CCAvoidBlack];
	}

	if (0 == [backgroundColors count])
	{
		// Hmm
		HBLogDebug(@"getColorsUsingCCColorCube: still no colors; grabbing everything");
		backgroundColors = foregroundColors;
	}

	// find a background color

	UIColor *backgroundColor = nil;
	UIColor *foregroundColor = nil;

	// default to first color returned
	if ([backgroundColors count] >= 1)
		backgroundColor = [backgroundColors objectAtIndex:0];

	// now look for a more colorful choice
	for (UIColor *thisColor in backgroundColors)
	{
		if (![self colorSeemsGrey:thisColor])
		{
			backgroundColor = thisColor;
			break;
		}
	}

	if (backgroundColor)
	{
		// now try to find a contrasting foreground color
		NSDictionary *backgroundColorDict = [backgroundColor CIE_LabDictionary];
		NSNumber *backgroundL = backgroundColorDict[kColoursCIE_L];
		double backgroundBrightness = [backgroundL doubleValue];

		for (UIColor *thisColor in foregroundColors)
		{
			NSDictionary *thisColorDict = [thisColor CIE_LabDictionary];
			NSNumber *thisL = thisColorDict[kColoursCIE_L];
			double thisBrightness = [thisL doubleValue];

			// 0 ... 100
			CGFloat distance = [thisColor distanceFromColor:backgroundColor type:ColorDistanceCIE2000];

			// wild guess
			if ((fabs(backgroundBrightness-thisBrightness) > 49.0) && (distance > 49.0))
			{
				HBLogDebug(@"getColorsUsingCCColorCube: found color with L difference: %0.2f  and CIE2000 distance: %0.2f",fabs(backgroundBrightness-thisBrightness),distance);
				foregroundColor = thisColor;
				break;
			}

		}
	}

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:foregroundColor];

//	[colorCube release];

	return badgeColors;
}

- (UIColor *)getBooverDominantColor:(UIImage *)image
{
	NSUInteger red = 0;
	NSUInteger green = 0;
	NSUInteger blue = 0;

	struct pixel { unsigned char r, g, b, a; };

	struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));

	if (pixels != nil)
	{
		CGContextRef context = CGBitmapContextCreate((void*) pixels,image.size.width,image.size.height,8,image.size.width * 4,CGImageGetColorSpace(image.CGImage),kCGImageAlphaPremultipliedLast);

		if (context != NULL)
		{
			// Draw the image in the bitmap

			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);

			// Now that we have the image drawn in our own buffer, we can loop over the pixels to
			// process it. This simple case simply counts all pixels that have a pure red component.

			// There are probably more efficient and interesting ways to do this. But the important
			// part is that the pixels buffer can be read directly.

			NSUInteger numberOfPixels = image.size.width * image.size.height;
			NSUInteger pixelsToOmit = 0;
			for (int i=0; i<numberOfPixels; i++)
			{
				NSUInteger threshhold = 210;

				if(pixels[i].r > threshhold)
				{
					if(pixels[i].g > threshhold)
					{
						if(pixels[i].b > threshhold)
						{
							pixelsToOmit++;
							continue;
						}
					}
				}

				red += pixels[i].r;
				green += pixels[i].g;
				blue += pixels[i].b;
			}

			numberOfPixels -= pixelsToOmit;

			red /= numberOfPixels;
			green /= numberOfPixels;
			blue /= numberOfPixels;

			CGContextRelease(context);
		}

		free(pixels);
	}

	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
}

- (CMBColorInfo *)getColorsUsingBooverAlgorithm:(UIImage *)image
{
	UIColor *backgroundColor = [self getBooverDominantColor:image];

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:nil];

	return badgeColors;
}

- (CMBColorInfo *)getColorsUsingColorBadges:(UIImage *)image
{
	if (COLORBADGESCLASS == nil)
		return nil;

	int badgeColor = [[COLORBADGESCLASS sharedInstance] colorForImage:image];

	UIColor *backgroundColor = UIColorFromRGB(badgeColor);

	CMBColorInfo *badgeColors = [[CMBColorInfo sharedInstance] colorInfoWithBackgroundColor:backgroundColor andForegroundColor:nil];

	return badgeColors;
}

@end

// vim:ft=objc
