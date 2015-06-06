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
    [self requestSongListForURI: context];
}

- (void)requestSongListForURI: (NSString *)URI {
    NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:URI, @"theURI", nil];

    [songListController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"array of songs: %@", [replyInfo objectForKey:@"titleArray"]);
            NSLog(@"array of songs: %@", [replyInfo objectForKey:@"URLArray"]);
            songArray = [replyInfo objectForKey:@"titleArray"];
            
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

- (void)setupTable {
    
    [self.songlistTable setNumberOfRows:[songArray count] withRowType:@"universalRowSong"];
    
    for (int i = 0; i < self.songlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.songlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:[songArray objectAtIndex:i]];
        [row.subtitleLabel setText:@"subtitle!"];
    }
}

/*
- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    
}
*/

@end



