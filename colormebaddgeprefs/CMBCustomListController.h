#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "CMBCustomListController.h"
#import "CMBColorPickerViewController.h"
#import "CMBColorPickerCell.h"
#import "external/HRColorPicker/UIColor+HRColorPickerHexColor.h"
#import "../CMBPreferences.h"

#define CMBLocalizedStringForKey(key) [self.tweakBundle localizedStringForKey:key value:@"" table:nil]

@interface CMBCustomListController : PSListController
@property (nonatomic,retain,readonly) NSMutableDictionary *tweakSettings;
@property (nonatomic,retain,readonly) NSBundle *tweakBundle;
@end

// vim:ft=objc
