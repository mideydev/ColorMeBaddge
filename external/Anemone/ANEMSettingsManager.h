// https://github.com/AnemoneTeam/Anemone/wiki/Extensibility
// https://github.com/AnemoneTeam/Anemone/wiki/No-Respring-Theme-Switch

@protocol AnemoneEventHandler
-(void)reloadTheme;
@end

@interface ANEMSettingsManager : NSObject
{
	NSArray *_themeSettings;
}
+ (instancetype)sharedManager;
- (NSArray *)themeSettings;
- (NSString *)themesDir;
- (void)forceReloadNow;
- (void)addEventHandler:(NSObject<AnemoneEventHandler> *)handler;
@end

// vim:ft=objc
