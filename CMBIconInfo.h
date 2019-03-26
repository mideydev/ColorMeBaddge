
@interface CMBIconInfo : NSObject
@property(nonatomic,strong)	id icon;
@property(nonatomic,copy)	NSString *nodeIdentifier;
@property(nonatomic,copy)	NSString *displayName;
@property(nonatomic)		BOOL isApplication;

+ (instancetype)sharedInstance;
- (CMBIconInfo *)getIconInfo:(id)icon;
- (id)realBadgeNumberOrString;
- (id)fakeBadgeNumberOrString;
@end

// vim:ft=objc
