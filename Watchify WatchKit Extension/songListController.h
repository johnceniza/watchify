//
//  songListController.h
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface songListController : WKInterfaceController {
    NSMutableDictionary *songlistDict;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *songlistTable;

@end
