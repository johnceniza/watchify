//
//  InterfaceController.m
//  Watchify WatchKit Extension
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import "InterfaceController.h"
#import "songListController.h"
#import "universalRow.h"

@interface InterfaceController()

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [self setupTempTable];
    
    NSDictionary *needAuth = [[NSDictionary alloc] initWithObjectsAndKeys:@"authMe",@"watchNeedsAuth", nil];
    [songListController openParentApplication:needAuth reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", replyInfo);
            
            if ([replyInfo objectForKey:@"authNeeded"]!= nil) {
                //request phone login
                [self setupAuthNeedTable];
            } else {
                NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
                playlistArray = [newDefault objectForKey:@"listOfPlaylists"];
                [self setupTable];
            }
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setupTempTable {
    [self.playlistTable setNumberOfRows:1 withRowType:@"universalRowID"];
    for (int i = 0; i < self.playlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.playlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:@"Loading playlists..."];
    }
}

- (void)setupAuthNeedTable {
    [self.playlistTable setNumberOfRows:1 withRowType:@"universalRowID"];
    for (int i = 0; i < self.playlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.playlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:@"Open iPhone app."];
        [row.subtitleLabel setText:@"Spotify login needed."];
    }
}

- (void)setupTable {
    
    [self.playlistTable setNumberOfRows:[[playlistArray objectForKey:@"playlistTitles"] count] withRowType:@"universalRowID"];
    NSArray *titles = [playlistArray objectForKey:@"playlistTitles"];
    NSArray *trackCounts = [playlistArray objectForKey:@"playlistTrackCounts"];

    for (int i = 0; i < self.playlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.playlistTable rowControllerAtIndex:i];
        [row.mainTitle setTextColor:[UIColor lightTextColor]];
        [row.subtitleLabel setTextColor:[UIColor lightTextColor]];
        [row.mainTitle setText:[titles objectAtIndex:i]];
        [row.subtitleLabel setText:[NSString stringWithFormat:@"%@ tracks", [trackCounts objectAtIndex:i]]];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    [[[table rowControllerAtIndex:rowIndex] mainTitle] setTextColor:[UIColor greenColor]];

    NSDictionary *songsInPlaylist = [[NSDictionary alloc] initWithObjectsAndKeys:[[playlistArray objectForKey:@"playlistTitles"] objectAtIndex:rowIndex],@"playlistTitle",[[playlistArray objectForKey:@"playlistURIs"] objectAtIndex:rowIndex], @"playlistURI",[[playlistArray objectForKey:@"playlistTrackCounts"] objectAtIndex:rowIndex], @"playlistTrackCount", nil];
    return songsInPlaylist;
}

@end



