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
        [self getPlaylists:self.session];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkLoginHistory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"sessionData"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        SPTSession *savedSession = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        self.session = savedSession;
        return YES;
    } else {
        return NO; //no login history so show login button
    }
}

- (void) authIsGood:(NSError*) theError andSesssion:(SPTSession *)theSession {
    if (theError != nil) {
        NSLog(@"*** Auth error: %@", theError);
    } else {
        [loginButton removeFromSuperview];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"sessionData"];
        [NSKeyedArchiver archiveRootObject:theSession toFile:filePath];
        
        self.session = theSession;
        [self getPlaylists:self.session];
    }
}

- (void)sharePlaylist: (NSMutableDictionary *) snapshot {
    NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
    NSArray *allKeys = [snapshot allKeys];
    
    for (int i = 0; i < [snapshot count]; i++) {
        NSString *newURL = [[snapshot objectForKey:[allKeys objectAtIndex:i]] absoluteString];
        
        [snapshot setObject:newURL forKey:[allKeys objectAtIndex:i]];
    }
    
    NSMutableDictionary *listOfPlaylistsToDisplay = [[NSMutableDictionary alloc] initWithDictionary:snapshot];
    [newDefault setObject:listOfPlaylistsToDisplay forKey:@"currentPlaylist"];
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
    
    NSMutableDictionary *playListDict = [[NSMutableDictionary alloc] init];

    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, SPTPlaylistList *playlists) {
        for (SPTPartialPlaylist *item in [playlists items]) {
            
            if (error) {
                NSLog(@"Error :%@", error);
            } else {
            //WIP - is it possible to have a playlist of the same name? Could confuse user - I expected playlsts to have unique ID to each of them per user but it doesn't seem like this is the case? In any case will show Playlist in the same order retreieved to clarify for user
            
            [playListDict setObject:[item uri] forKey:[item name]];
                
            }
        }
        
        [self getSongList: playListDict];
        [self sharePlaylist: playListDict];
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

@end
