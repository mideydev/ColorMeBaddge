//#import <Foundation/Foundation.h>
#import "SpringBoard.h"
#import "CMBManager.h"
#import "CMBPreferences.h"

%hook SBIconImageView

@interface SBIconImageView : UIView
@property (nonatomic,readonly) SBIcon *icon;
@end

-(void)iconImageDidUpdate:(id)arg1
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		%orig();
		return;
	}

	%orig();

	CMBIconInfo *iconInfo = [[CMBIconInfo sharedInstance] getIconInfo:[self icon]];

	if (iconInfo.isApplication == YES)
	{
		HBLogDebug(@"icon image did update: %@", iconInfo.nodeIdentifier);
		[[CMBManager sharedInstance] refreshBadges:iconInfo.nodeIdentifier];
	}
}

%end

// vim:ft=objc
