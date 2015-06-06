//
//  ViewController.m
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import "ViewController.h"
#import <Spotify/Spotify.h>

@interface ViewController ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

static NSString * const kClientId = @"a7d6ad4806134d61aa38eb219fae13ff";
static NSString * const kCallbackURL = @"watchifyspotify://";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //if statement to check if already logged in
    
    if (![self checkLoginHistory]) {
        //show login screen
        [self createLoginButton];
    } else {
        //show player screen
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkLoginHistory {
    return NO; //no login history so show login button
}

- (void) authIsGood:(NSError*) theError {
    NSLog(@"do we make it here?");
    if (theError != nil) {
        NSLog(@"*** Auth error: %@", theError);
    } else {
        NSLog(@"Authentication Complete! - we should probably play something");
    }
}

#pragma mark - View Creation -

- (void) createLoginButton {
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0, 0, 200, 120);
    loginButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [loginButton setTitle:@"Connect to Spotify" forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor blackColor]];
    [loginButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

#pragma mark - Spotify Methods -

- (void)loginRequest {
    [[SPTAuth defaultInstance] setClientID:kClientId];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:kCallbackURL]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [[UIApplication sharedApplication] openURL:loginURL];
}

-(void)playUsingSession:(SPTSession *)session {
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        
        NSURL *trackURI = [NSURL URLWithString:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp"];
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}

@end
