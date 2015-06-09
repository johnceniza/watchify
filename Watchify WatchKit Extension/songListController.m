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
    [self requestSongsInPlaylist: context];
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

- (void)setupTable{
    
    [self.songlistTable setNumberOfRows:[[songlistDict objectForKey:@"songTitles"] count] withRowType:@"universalRowSong"];
    
    for (int i = 0; i < self.songlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.songlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:[[songlistDict objectForKey:@"songTitles"] objectAtIndex:i]];
        [row.subtitleLabel setText:@"Artist"];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    
    //WIP - in the future need to add artist and track time when we figure out how to pull that from appdelegate (right now it can't handle passing back all of that only track title and URI)
    
    NSDictionary *songSelected = [[NSDictionary alloc] initWithObjectsAndKeys:[songlistDict objectForKey:@"songTitles"],@"songTitleList",[songlistDict objectForKey:@"songURIs"], @"songURISelected", [NSNumber numberWithLong:rowIndex], @"playIndex", nil];
    
    return (songSelected);
}

@end



