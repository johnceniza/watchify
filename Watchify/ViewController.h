//
//  ViewController.h
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface ViewController : UIViewController {
    UIButton *loginButton;
}

- (void)authIsGood: (NSError *) theError andSesssion: (SPTSession *)theSession;

@end

