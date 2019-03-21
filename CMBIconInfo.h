
@interface CMBIconInfo : NSObject
@property(nonatomic,strong)	id icon;
@property(nonatomic,copy)	NSString *nodeIdentifier;
//@property(nonatomic,strong)	UIImage *image;
//@property(nonatomic,strong)	UIImage *unmaskedImage;
@property(nonatomic)		BOOL isApplication;
//@property(nonatomic)		BOOL isFolder;

+ (instancetype)sharedInstance;
- (CMBIconInfo *)getIconInfo:(id)icon;
- (id)realBadgeNumberOrString;
@end

// vim:ft=objc
