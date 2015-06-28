//
//  songListController.m
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import "songListController.h"
#import "universalRow.h"

@interface songListController ()

@end

@implementation songListController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
    [self setupTempTable];
    
    NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
    NSMutableDictionary *listOfSongs = [[NSMutableDictionary alloc] initWithDictionary:context];
    [newDefault setObject:listOfSongs forKey:@"currentPickedPlaylist"];
    [newDefault synchronize];
}

- (void)requestSongsInPlaylist: (NSDictionary *)playlistDict {
    
    [songListController openParentApplication:playlistDict reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            songlistDict = [[NSMutableDictionary alloc] initWithDictionary:replyInfo];
            [self setupTable];
        }
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    NSDictionary *needAuth = [[NSDictionary alloc] initWithObjectsAndKeys:@"authMe",@"watchNeedsAuth", nil];
    
    [songListController openParentApplication:needAuth reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"%@", replyInfo);
        if (error) {
            NSLog(@"%@", error);
        } else {
            if ([replyInfo objectForKey:@"authNeeded"]!= nil) {
                //request phone login
                [self setupAuthNeedTable];
            } else {
                NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
                [self requestSongsInPlaylist: [newDefault objectForKey:@"currentPickedPlaylist"]];
            }
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setupTempTable {
    [self.songlistTable setNumberOfRows:1 withRowType:@"universalRowSong"];
    for (int i = 0; i < self.songlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.songlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:@"Loading tracks..."];
    }
}

- (void)setupAuthNeedTable {
    [self.songlistTable setNumberOfRows:1 withRowType:@"universalRowSong"];
    for (int i = 0; i < self.songlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.songlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:@"Open iPhone app."];
        [row.subtitleLabel setText:@"Spotify login needed."];
    }
}

- (void)setupTable{
    
    [self.songlistTable setNumberOfRows:[[songlistDict objectForKey:@"songTitles"] count] withRowType:@"universalRowSong"];
    
    for (int i = 0; i < self.songlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.songlistTable rowControllerAtIndex:i];
        [row.mainTitle setTextColor:[UIColor lightTextColor]];
        [row.subtitleLabel setTextColor:[UIColor lightTextColor]];
        [row.mainTitle setText:[[songlistDict objectForKey:@"songTitles"] objectAtIndex:i]];
        [row.subtitleLabel setText:@"Artist"];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    
    [[[table rowControllerAtIndex:rowIndex] mainTitle] setTextColor:[UIColor greenColor]];

    NSDictionary *songSelected = [[NSDictionary alloc] initWithObjectsAndKeys:[songlistDict objectForKey:@"songTitles"],@"songTitleList",[songlistDict objectForKey:@"songURIs"], @"songURISelected", [NSNumber numberWithLong:rowIndex], @"playIndex", nil];

    [songListController openParentApplication:songSelected reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", replyInfo);
        }
    }];
}

@end



