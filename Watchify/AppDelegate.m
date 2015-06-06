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

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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
        NSLog(@"need to Authenticate using Watchify iPhone App");
    }
    
    if ([userInfo objectForKey:@"theURI"]) {
        
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"theURI"]];
        
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
        
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"playThisSong"]];
        /*
        [self.player loginWithSession:self.session callback:^(NSError *error) {
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
         */
    }
}

@end
