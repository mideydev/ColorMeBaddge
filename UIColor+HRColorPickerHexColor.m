#import "UIColor+HRColorPickerHexColor.h"

@implementation UIColor (HRColorPickerHexColor)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
	unsigned int rgb = 0;
	NSString *cleanedString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	NSScanner *scanner = [NSScanner scannerWithString:cleanedString];
	[scanner scanHexInt:&rgb];

	CGFloat r, g, b;

	r = ((rgb & 0xFF0000) >> 16) / 255.0;
	g = ((rgb & 0xFF00) >> 8) / 255.0;
	b = (rgb & 0xFF) / 255.0;

	UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];

	HBLogDebug(@"colorFromHexString: %@ => %@ => %@",hexString,cleanedString,color);

	return color;
}

// midey: https://github.com/hayashi311/Color-Picker-for-iOS/issues/29
#if 0
- (NSString *)hexString
{
	// needs to match HRColorPicker info view
	CGFloat r, g, b, a;
	[self getRed:&r green:&g blue:&b alpha:&a];

	int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;

	NSString *hexString = [NSString stringWithFormat:@"#%06X", rgb];
	HBLogDebug(@"hexString: %f / %f / %f => %@",r,g,b,hexString);

	return hexString;
}
#else
- (NSString *)hexString
{
    CGFloat rFloat, gFloat, bFloat, aFloat;
    [self getRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];

    int r, g, b;
    r = (int)ceilf(255.0 * rFloat);
    g = (int)ceilf(255.0 * gFloat);
    b = (int)ceilf(255.0 * bFloat);

    NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
	HBLogDebug(@"hexString: %f / %f / %f => %@",rFloat,gFloat,bFloat,hexString);

	return hexString;
}
#endif

@end

