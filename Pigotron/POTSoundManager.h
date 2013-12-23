//
//  POTSoundManager.h
//  Pigotron
//
//  Created by Jack Flintermann on 12/21/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POTSoundManager : NSObject

+ (instancetype) sharedManager;

- (void) playRandomSound;
- (void) playSoundNamed:(NSString *)name;

@end
