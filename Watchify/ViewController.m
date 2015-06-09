//
//  ViewController.m
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

/*
 
 todo
 
 1. save session
 2. show playlist on table
 3. show song list on table
 
 watch:
 
 1. add bool to detect where screen closed (song list or play list) if song list - auto navigate to the song list

 */

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (atomic, readwrite) BOOL firstLoad;
@end

static NSString * const kClientId = @"a7d6ad4806134d61aa38eb219fae13ff";
static NSString * const kCallbackURL = @"watchifyspotify://";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.firstLoad = YES;
    [self checkSession];
}

- (void)checkSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    // Check if we have a token at all
    if (auth.session == nil) {
        [self createLoginButton];
    }
    
    // Check if it's still valid
    if ([auth.session isValid] && self.firstLoad) {
        // It's still valid, show the player.
        [self getPlaylists:self.session];
        return;
    }
    
    // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
    if (auth.hasTokenRefreshService) {
        [self renewTokenAndShowPlayer];
    }
}

- (void)renewTokenAndShowPlayer {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        NSData *authSessionData = [NSKeyedArchiver archivedDataWithRootObject:auth.session];
        
        NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
        [newDefault setObject:authSessionData forKey:@"authSessionDataKey"];
        [newDefault synchronize];
        
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self getPlaylists:self.session];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) authIsGood:(NSError*) theError andSesssion:(SPTSession *)theSession {
    if (theError != nil) {
        NSLog(@"*** Auth error: %@", theError);
    } else {
        [loginButton removeFromSuperview];
        
        SPTAuth *auth = [SPTAuth defaultInstance];

        auth.session = theSession;
        
        NSData *authSessionData = [NSKeyedArchiver archivedDataWithRootObject:auth.session];
        
        NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
        [newDefault setObject:authSessionData forKey:@"authSessionDataKey"];
        [newDefault synchronize];

        [self getPlaylists:auth.session];
    }
}

- (void)sharePlaylist: (NSMutableDictionary *) snapshot {
    NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
    NSMutableDictionary *listOfPlaylistsToDisplay = [[NSMutableDictionary alloc] initWithDictionary:snapshot];
    [newDefault setObject:listOfPlaylistsToDisplay forKey:@"listOfPlaylists"];
    [newDefault synchronize];
}

#pragma mark - View Creation -

- (void) createLoginButton {
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
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

- (void)getPlaylists: (SPTSession *)session {
    self.firstLoad = NO;

    NSMutableDictionary *playlistDict = [[NSMutableDictionary alloc] init];
    
    /*3 keys in dict
         1. playlists
         2. playlist URIs
         3. # of tracks
     */
    
    NSMutableArray *playlistTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *playlistURIArray = [[NSMutableArray alloc] init];
    NSMutableArray *playlistTrackCountArray = [[NSMutableArray alloc] init];

    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, SPTPlaylistList *playlists) {
        for (SPTPartialPlaylist *item in [playlists items]) {
            if (error) {
                NSLog(@"Error :%@", error);
            } else {
                [playlistTitleArray addObject:[item name]];
                [playlistURIArray addObject:[[item uri] absoluteString]];
                [playlistTrackCountArray addObject:[NSNumber numberWithInteger:[item trackCount]]];
            }
        }
        
        [playlistDict setObject:playlistTitleArray forKey:@"playlistTitles"];
        [playlistDict setObject:playlistURIArray forKey:@"playlistURIs"];
        [playlistDict setObject:playlistTrackCountArray forKey:@"playlistTrackCounts"];

        //[self getSongList: playlistDict];
        [self sharePlaylist: playlistDict];
    }];
}

- (void)getSongList: (NSDictionary *)playlist {
    //pick one for testing purposes
    //NSString *pickedPlaylist = @"CDSK";

    /*
    //show song list
    [SPTPlaylistSnapshot playlistWithURI:[playlist objectForKey:pickedPlaylist] session:self.session callback:^(NSError *error, SPTPlaylistSnapshot *songList) {
        
        [self playPlaylist:songList withSession:self.session];

        //WIP - add code to show song list on display and keep track of index that's how we will figure out what is playing/user wants to play
    }];
     */
}

- (void)playPlaylist: (SPTPlaylistSnapshot *)playlistSnapshot withSession: (SPTSession *) session {
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    //Extract URI here for playing purposes only - need to really keep track of tracks in its entirety for title display, length, etc.
    NSMutableArray *uriIndex = [[NSMutableArray alloc] init];

    for (int i = 0; i<[playlistSnapshot.firstTrackPage.items count]; i++) {
        [uriIndex addObject:[[playlistSnapshot.firstTrackPage.items objectAtIndex:i] uri]];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        
        [self.player playURIs:uriIndex fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}

- (SPTAuth *)giveMeAuth {
    SPTAuth *auth = [SPTAuth defaultInstance];
    NSLog(@"%@",auth);
    return auth;
}

@end
