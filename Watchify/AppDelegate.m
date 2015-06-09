//
//  AppDelegate.m
//  Watchify
//
//  Created by John Ceniza on 6/6/15.
//  Copyright (c) 2015 AppDeco. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application handleOpenURL:(NSURL *)url {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            ViewController *mainViewController = (ViewController *)self.window.rootViewController;
            [mainViewController authIsGood:error andSesssion: session];
            
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    
    if ([userInfo objectForKey:@"watchNeedsAuth"]) {
        
        NSUserDefaults *newDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.appDeco.watchify"];
        
        if ([newDefault objectForKey:@"sessionDataKey"]) {
            
            SPTSession *savedSession = [NSKeyedUnarchiver unarchiveObjectWithData:[newDefault objectForKey:@"sessionDataKey"]];
            self.session = savedSession;
            
            NSDictionary *authSuccess = [[NSDictionary alloc] initWithObjectsAndKeys:@"Authentication successful",@"authSuccess", nil];
            reply(authSuccess);

        } else {
            NSDictionary *authNeeded = [[NSDictionary alloc] initWithObjectsAndKeys:@"Please launch iPhone app to authenticate Sptofiy login.",@"authNeeded", nil];
            reply(authNeeded);
        }
    
    } else if ([userInfo objectForKey:@"playlistURI"]) {
        
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"playlistURI"]];

        __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
        bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // increase the time to a larger value if you still don't get the data!
            [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
        });
        
        [SPTPlaylistSnapshot playlistWithURI:url session:self.session callback:^(NSError *error, SPTPlaylistSnapshot *songList) {
            NSMutableDictionary *songlistDictionary = [[NSMutableDictionary alloc] init];
            /*4 keys in dict
             1. track name
             2. track URI
             3. track artist
             4. track length
             */
            
            //WIP - want to get all of these but don't have enough time to get all four - so far just name and URI can come through. Need to find a way to optimize loop/initing dictionary or something - need at least artist name (length we can drop if need be)
            
            NSMutableArray *trackTitleArray = [[NSMutableArray alloc] init];
            NSMutableArray *trackURIArray = [[NSMutableArray alloc] init];
            //NSMutableArray *trackArtistArray = [[NSMutableArray alloc] init];
            //NSMutableArray *trackLengthArray = [[NSMutableArray alloc] init];

            for (int i = 0; i<[songList.firstTrackPage.items count]; i++) {
                [trackTitleArray addObject:[[songList.firstTrackPage.items objectAtIndex:i] name]];
                [trackURIArray addObject:[[[songList.firstTrackPage.items objectAtIndex:i] uri] absoluteString]];
                //[trackArtistArray addObject:[[songList.firstTrackPage.items objectAtIndex:i] artists]];
                //[trackLengthArray addObject:[NSNumber numberWithInteger:[[songList.firstTrackPage.items objectAtIndex:i] length]]];
            }
            
            [songlistDictionary setObject:trackTitleArray forKey:@"songTitles"];
            [songlistDictionary setObject:trackURIArray forKey:@"songURIs"];
            //[songlistDictionary setObject:trackArtistArray forKey:@"songArtists"];
            //[songlistDictionary setObject:trackLengthArray forKey:@"songLengths"];

            reply(songlistDictionary);
            
        }];
        
    } else if ([userInfo objectForKey:@"songTitleList"]) {
        
        NSArray *arrayOfURIStrings = [userInfo objectForKey:@"songURISelected"];
        NSMutableArray *arrayOfURIs = [[NSMutableArray alloc] init];
        int indexToPlay = [[userInfo objectForKey:@"playIndex"] intValue];
        
        for (int i = 0; i < [arrayOfURIStrings count]; i++) {
            NSURL *URLfromString = [NSURL URLWithString:[arrayOfURIStrings objectAtIndex:i]];
            [arrayOfURIs addObject:URLfromString];
        }

        if (self.player == nil) {
            self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
        }
        
        if (self.player.isPlaying) {
            [self.player stop:nil];
            [self.player playURIs:arrayOfURIs fromIndex:indexToPlay callback:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"*** Starting playback got error: %@", error);
                    NSDictionary *errorDict = [[NSDictionary alloc] initWithObjectsAndKeys:error,@"errorKey", nil];
                    reply(errorDict);
                }
                NSDictionary *successPlaying = [[NSDictionary alloc] initWithObjectsAndKeys:@"Playing Song after stopping!",@"success", nil];
                reply(successPlaying);
            }];
        } else {

            __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
            bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // increase the time to a larger value if you still don't get the data!!! I used 2 secs previously but my network is too weak!!!
                [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
            });
            
            [self.player loginWithSession:self.session callback:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"*** Logging in got error: %@", error);
                    NSDictionary *errorDict = [[NSDictionary alloc] initWithObjectsAndKeys:error,@"errorKey", nil];
                    reply(errorDict);
                }
                
                [self.player playURIs:arrayOfURIs fromIndex:indexToPlay callback:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"*** Starting playback got error: %@", error);
                        NSDictionary *errorDict = [[NSDictionary alloc] initWithObjectsAndKeys:error,@"errorKey", nil];
                        reply(errorDict);
                    }
                    NSDictionary *successPlaying = [[NSDictionary alloc] initWithObjectsAndKeys:@"Playing Song after initializing player!",@"success", nil];
                    reply(successPlaying);
                }];
            }];
        }
        
    } else if ([userInfo objectForKey:@"playPause"]) {
        if (self.player.isPlaying) {
            //pause
            [self.player setIsPlaying:NO callback:nil];
            NSDictionary *successPausing = [[NSDictionary alloc] initWithObjectsAndKeys:@"Track Paused",@"delegateFeedback", nil];
            reply(successPausing);
        } else {
            //play
            [self.player setIsPlaying:YES callback:nil];
            NSDictionary *successPausing = [[NSDictionary alloc] initWithObjectsAndKeys:@"Track Played",@"delegateFeedback", nil];
            reply(successPausing);
        }
    } else {
        
        NSDictionary *successPlaying = [[NSDictionary alloc] initWithObjectsAndKeys:@"There's been an error :(",@"error", nil];
        reply(successPlaying);

        reply(nil);
    }
}

@end
