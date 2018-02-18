#import "SpringBoard.h"
#import "CMBPreferences.h"

%hook SBIconController

- (BOOL)iconAllowsBadging:(id)arg1
{
	if (![[CMBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	BOOL retval = %orig();

	if ([[CMBPreferences sharedInstance] showAllBadges])
		return YES;

	return retval;
}

%end

// vim:ft=objc
