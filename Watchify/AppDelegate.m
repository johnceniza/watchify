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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"sessionData"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        SPTSession *savedSession = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.session = savedSession;
    } else {
        NSDictionary *authNeeded = [[NSDictionary alloc] initWithObjectsAndKeys:@"Please launch iPhone app to authenticate Sptofiy login.",@"authNeeded", nil];
        reply(authNeeded);
    }
    
    if ([userInfo objectForKey:@"theURI"]) {
        
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"theURI"]];
        
        __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
        bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // increase the time to a larger value if you still don't get the data!!! I used 2 secs previously but my network is too weak!!!
            [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
        });
        
        [SPTPlaylistSnapshot playlistWithURI:url session:self.session callback:^(NSError *error, SPTPlaylistSnapshot *songList) {
            NSMutableArray *arrayOfTitles = [[NSMutableArray alloc] init];
            NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
            
            for (int i = 0; i<[songList.firstTrackPage.items count]; i++) {
                [arrayOfTitles addObject:[[songList.firstTrackPage.items objectAtIndex:i] name]];
                [arrayOfURLs addObject:[[[songList.firstTrackPage.items objectAtIndex:i] uri] absoluteString]];
            }
            
            NSDictionary *dictOfTitles = [[NSDictionary alloc] initWithObjectsAndKeys:arrayOfTitles,@"titleArray",arrayOfURLs,@"URLArray", nil];
            
            reply(dictOfTitles);
            
        }];
        
    } else if ([userInfo objectForKey:@"playThisSong"]) {
        
        NSArray *arrayOfURIStrings = [userInfo objectForKey:@"playThisSong"];
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
                NSDictionary *successPlaying = [[NSDictionary alloc] initWithObjectsAndKeys:@"Playing Song!",@"errorKey", nil];
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
                    NSDictionary *successPlaying = [[NSDictionary alloc] initWithObjectsAndKeys:@"Playing Song!",@"errorKey", nil];
                    reply(successPlaying);
                }];
            }];
        }
        
    } else {
        
        reply(nil);
    }
}

@end
