//
//  playerInterfaceController.m
//  Watchify
//
//  Created by John Ceniza on 6/7/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import "playerInterfaceController.h"


@interface playerInterfaceController ()

@end

@implementation playerInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    playerDictionary = [[NSMutableDictionary alloc] initWithDictionary:context];

    [playerInterfaceController openParentApplication:context reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self setupPlayer];
            NSLog(@"%@", replyInfo);
        }
    }];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setupPlayer {
    [self.songTitle setText:[[playerDictionary objectForKey:@"songTitleList"] objectAtIndex:[[playerDictionary objectForKey:@"playIndex"] intValue]]];
    [self.artistLabel setText:@"Artist"];
}

- (IBAction)nextTrack:(id)sender {
    int indexCalc = [[playerDictionary objectForKey:@"theIndex"] intValue]+1;
    NSNumber *indexNS = [NSNumber numberWithInteger:indexCalc];
    [playerDictionary setObject:indexNS forKey:@"theIndex"];
    
    [playerInterfaceController openParentApplication:playerDictionary reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self setupPlayer];
            NSLog(@"%@", replyInfo);
        }
    }];
}

- (IBAction)prevTracak:(id)sender {
    
}

- (IBAction)playOrPause:(id)sender {
    NSMutableDictionary *playPauseRequest = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Play Or Pause",@"playPause", nil];
    
    [playerInterfaceController openParentApplication:playPauseRequest reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", replyInfo);
        }
    }];
}

@end



