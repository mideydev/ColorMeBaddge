#import "CMBRootListController.h"
#import <notify.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// preferred height should be at least half header height
#define HEADER_HEIGHT 320.0
#define HEADER_MARGIN 20.0
#define PREFERRED_HEIGHT ((HEADER_HEIGHT / 2.0) + HEADER_MARGIN)

#define COLORBADGESCLASS objc_getClass("ColorBadges")

@implementation CMBRootListController

- (id)init
{
	self = [super init];

	if (self)
	{
		_audioPlayer = nil;
		_rubYouDownURL = [[NSURL alloc] initFileURLWithPath:@"/Library/PreferenceBundles/ColorMeBaddgePrefs.bundle/ColorMeBaddgeRubYouDown.mp3"];
	}

	return self;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	[super setPreferenceValue:value specifier:specifier];

	id tweakEnabledSpecifier = [self specifierForID:@"CMBTweakEnabled"];

	if (specifier == tweakEnabledSpecifier)
		[self showColorBadgesWarningIfBothEnabled];
}

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"ColorMeBaddgePrefs" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,PREFERRED_HEIGHT);

//	UIImage *headerImage = [[[UIImage alloc]
//		initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ColorMeBaddgePrefs.bundle"] pathForResource:@"ColorMeBaddgeHeader" ofType:@"jpg"]] autorelease];
	UIImage *headerImage = [[UIImage alloc]
		initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ColorMeBaddgePrefs.bundle"] pathForResource:@"ColorMeBaddgeHeader" ofType:@"jpg"]];

//	UIImageView *headerView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:frame];

	[headerView setImage:headerImage];
	[headerView setBackgroundColor:[UIColor blackColor]];
	[headerView setContentMode:UIViewContentModeCenter];
	[headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rubYouDown:)];

	[headerView addGestureRecognizer:tap];
	[headerView setUserInteractionEnabled:YES];

	self.table.tableHeaderView = headerView;

	[self showColorBadgesWarningIfBothEnabled];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	CGRect wrapperFrame = ((UIView *)self.table.subviews[0]).frame; // UITableViewWrapperView
	CGRect frame = CGRectMake(wrapperFrame.origin.x,self.table.tableHeaderView.frame.origin.y,wrapperFrame.size.width,self.table.tableHeaderView.frame.size.height);

	self.table.tableHeaderView.frame = frame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
	return PREFERRED_HEIGHT;
}

- (void)respring
{
	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:CMBLocalizedStringForKey(@"RESPRING_CONFIRMATION_TITLE")
								message:CMBLocalizedStringForKey(@"RESPRING_CONFIRMATION_MESSAGE")
								preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yesButton = [UIAlertAction
								actionWithTitle:CMBLocalizedStringForKey(@"CONFIRMATION_YES")
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									notify_post("org.midey.colormebaddge/respringRequested");
								}];

	UIAlertAction* noButton = [UIAlertAction
								actionWithTitle:CMBLocalizedStringForKey(@"CONFIRMATION_NO")
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									//Do nothing
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)showColorBadgesWarningIfBothEnabled
{
	static int warned = 0;
	void *dlhandle = NULL;

	if (warned)
		return;

	id tweakEnabledSpecifier = [self specifierForID:@"CMBTweakEnabled"];

	if (!tweakEnabledSpecifier)
		return;

	id tweakEnabled = [self readPreferenceValue:tweakEnabledSpecifier];

	if (![tweakEnabled boolValue])
		return;

	dlhandle = dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBadges.dylib",RTLD_LAZY);

	if (dlhandle)
		dlclose(dlhandle);

	if (COLORBADGESCLASS == nil)
		return;

	BOOL colorBadgesEnabled = [COLORBADGESCLASS isEnabled];

	if (!colorBadgesEnabled)
		return;

	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:CMBLocalizedStringForKey(@"COLORBADGES_WARNING_TITLE")
								message:CMBLocalizedStringForKey(@"COLORBADGES_WARNING_MESSAGE")
								preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* okButton = [UIAlertAction
								actionWithTitle:CMBLocalizedStringForKey(@"CONFIRMATION_OK")
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									//Do nothing
								}];

	[alert addAction:okButton];

	[self presentViewController:alert animated:YES completion:nil];

	warned = 1;
}

- (void)rubYouDown:(UITapGestureRecognizer *)tapGesture
{
	BOOL startRubDown = YES;

	if (_audioPlayer)
	{
		if ([_audioPlayer isPlaying])
		{
			[_audioPlayer stop];
			startRubDown = NO;
		}

//		[_audioPlayer release];
		_audioPlayer = nil;
	}

	if (startRubDown)
	{
		_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_rubYouDownURL error:nil];
		_audioPlayer.numberOfLoops = -1;
		_audioPlayer.volume = 0.5;
		[_audioPlayer play];
	}
}

@end

// vim:ft=objc
