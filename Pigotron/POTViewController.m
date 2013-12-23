//
//  POTViewController.m
//  Pigotron
//
//  Created by Jack Flintermann on 12/21/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "POTViewController.h"
#import "POTSoundManager.h"
#import <Pusher/Pusher.h>
#import <AFNetworking/AFNetworking.h>

@interface POTViewController()<PTPusherDelegate>
@property(nonatomic, strong) PTPusher *client;
@end

@implementation POTViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.client = [PTPusher pusherWithKey:@"4714f56d5e7077fd98d2" delegate:self encrypted:NO];
    [self.client connect];
    PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"sounds"];
    [channel bindToEventNamed:@"new-sound" handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received
        NSString *url = [channelEvent.data objectForKey:@"url"];
        NSString *name = [[channelEvent.data objectForKey:@"name"]
                          stringByAppendingString:@".wav"];
        if (!url || !name) {
            return;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", path);
            [[POTSoundManager sharedManager] playSoundNamed:name];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    }];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
    
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
    
}

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
