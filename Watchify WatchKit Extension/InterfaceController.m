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

    NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
    playlistArray = [newDefault objectForKey:@"currentPlaylist"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self setupTable];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setupTable {
    
    [self.playlistTable setNumberOfRows:[playlistArray count] withRowType:@"universalRowID"];
    NSArray *titles = [playlistArray allKeys];
    NSArray *uris = [playlistArray allValues];
    
    for (int i = 0; i < self.playlistTable.numberOfRows; i++)
    {
        universalRow *row = [self.playlistTable rowControllerAtIndex:i];
        [row.mainTitle setText:[titles objectAtIndex:i]];
        [row.subtitleLabel setText:[uris objectAtIndex:i]];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    NSArray *allkeys = [playlistArray allKeys];
    return [playlistArray objectForKey:[allkeys objectAtIndex:rowIndex]];
}

@end



