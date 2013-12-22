//
//  POTSoundManager.m
//  Pigotron
//
//  Created by Jack Flintermann on 12/21/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "POTSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface POTSoundManager() {
    NSMutableArray *soundIds;
}
@end

@implementation POTSoundManager

+ (instancetype) sharedManager {
    static POTSoundManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void) dealloc {
    for (NSNumber *number in soundIds) {
        AudioServicesDisposeSystemSoundID([number unsignedIntegerValue]);
    }
    soundIds = nil;
}

- (id) init {
    self = [super init];
    if (self) {
        NSArray *urls = [self allLocalSoundURLs];
        soundIds = [NSMutableArray array];
        for (NSURL *url in urls) {
            SystemSoundID soundId;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
            [soundIds addObject:@(soundId)];
        }
    }
    return self;
}

- (NSArray *) allLocalSoundURLs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'wav'"];
    return [contents filteredArrayUsingPredicate:predicate];
}

- (void) playRandomSound {
    if ([soundIds count] > 0) {
        NSNumber *number = soundIds[arc4random_uniform([soundIds count])];
        AudioServicesPlaySystemSound([number unsignedIntegerValue]);
    }
}

@end
