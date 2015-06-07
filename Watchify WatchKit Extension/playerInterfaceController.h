//
//  playerInterfaceController.h
//  Watchify
//
//  Created by John Ceniza on 6/7/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface playerInterfaceController : WKInterfaceController {
    NSMutableDictionary *playerDictionary;
}

@property (weak, nonatomic) IBOutlet WKInterfaceButton *playButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *nextButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *prevButton;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *volumeSlider;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *songTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *artistLabel;

@end
