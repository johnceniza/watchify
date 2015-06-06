//
//  InterfaceController.h
//  Watchify WatchKit Extension
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController {
    NSMutableDictionary *playlistArray;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *playlistTable;

@end
