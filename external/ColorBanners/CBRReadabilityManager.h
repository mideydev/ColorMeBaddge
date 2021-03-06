//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//#import "NSObject.h"

@interface CBRReadabilityManager : NSObject
{
    _Bool _shouldUseDarkText;
    id <CBRReadabilityManagerDelegate> _delegate;
}

+ (id)sharedInstance;
@property(nonatomic) id <CBRReadabilityManagerDelegate> delegate; // @synthesize delegate=_delegate;
@property(nonatomic) _Bool shouldUseDarkText; // @synthesize shouldUseDarkText=_shouldUseDarkText;
- (void)setShouldUseDarkTextAndSynchronize:(_Bool)arg1;
- (void)refresh;
- (void)dealloc;
- (id)init;

@end

