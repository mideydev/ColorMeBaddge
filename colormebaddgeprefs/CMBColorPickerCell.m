#import "CMBColorPickerCell.h"
#import "CMBColorPickerViewController.h"
#import "UIColor+HRColorPickerHexColor.h"

@implementation CMBColorPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];

	if (self)
	{
	}

	return self;
}

- (void)updateColorPreview
{
	self.detailTextLabel.text = [_color hexString];
	self.detailTextLabel.alpha = 0.65;

//	UIView *colorPreview = [[[UIView alloc] init] autorelease];
	UIView *colorPreview = [[UIView alloc] init];
	colorPreview.frame = CGRectMake(0, 0, 29, 29);
	colorPreview.backgroundColor = _color;
	colorPreview.layer.cornerRadius = colorPreview.frame.size.width / 2;
	colorPreview.layer.borderWidth = 1;
	colorPreview.layer.borderColor = [UIColor grayColor].CGColor;

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorPreviewTapped:)];
	[colorPreview addGestureRecognizer:tap];

	[self setAccessoryView:colorPreview];
}

- (void)colorPreviewTapped:(id)sender
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didTapColorPreviewAtIndexPath:)])
		[self.delegate didTapColorPreviewAtIndexPath:_indexPath];
}

@end

// vim:ft=objc
