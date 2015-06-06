//
//  universalRow.h
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface universalRow : NSObject {
    
}

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *mainTitle;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *subtitleLabel;

@end
