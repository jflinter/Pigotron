//
//  POTViewController.m
//  Pigotron
//
//  Created by Jack Flintermann on 12/21/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "POTViewController.h"
#import "POTSoundManager.h"

@implementation POTViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [[POTSoundManager sharedManager] playRandomSound];
    }
}

@end
