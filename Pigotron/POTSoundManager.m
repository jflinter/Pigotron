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
    NSMutableDictionary *sounds;
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
    [self clearSoundCache];
}

- (void) clearSoundCache {
    for (NSNumber *number in [sounds allValues]) {
        AudioServicesDisposeSystemSoundID([number unsignedIntegerValue]);
    }
    sounds = nil;
}

- (void) buildSoundCache {
    [self clearSoundCache];
    NSArray *urls = [self allLocalSoundURLs];
    sounds = [NSMutableDictionary dictionary];
    for (NSURL *url in urls) {
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
        [sounds setObject:@(soundId) forKey:[[url path] lastPathComponent]];
    }
}

- (NSArray *) allLocalSoundURLs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSURL *documentsURL = [NSURL URLWithString:[self applicationDocumentsDirectory]];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    NSArray *documents = [fileManager contentsOfDirectoryAtURL:documentsURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    contents = [contents arrayByAddingObjectsFromArray:documents];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'wav'"];
    NSArray *urls = [contents filteredArrayUsingPredicate:predicate];
    return urls;
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void) playRandomSound {
    if (!sounds) {
        [self buildSoundCache];
    }
    if ([[sounds allValues] count] > 0) {
        NSNumber *number = [sounds allValues][arc4random_uniform([[sounds allValues] count])];
        AudioServicesPlaySystemSound([number unsignedIntegerValue]);
    }
}

- (void) playSoundNamed:(NSString *)name {
    [self buildSoundCache];
    NSNumber *number = [sounds objectForKey:name];
    if (number) {
        AudioServicesPlaySystemSound([number unsignedIntegerValue]);
    }
}

@end
