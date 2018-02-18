#import <Preferences/PSTableCell.h>

@protocol CMBColorPickerCellDelegate <NSObject>
- (void)didTapColorPreviewAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface CMBColorPickerCell : PSTableCell
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSIndexPath *indexPath;
@property (nonatomic,retain) UIColor *color;
- (void)updateColorPreview;
@end

// vim:ft=objc
