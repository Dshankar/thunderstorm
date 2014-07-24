//
//  AppDelegate.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "AppDelegate.h"
#import "WriterTableViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSDictionary *defaultTimelineData = [[NSDictionary alloc] initWithObjects:@[@"",@""] forKeys:@[@"title", @"description"]];
    NSDictionary *defaultTimelineNumberOfLines = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:1], [NSNumber numberWithInt: 1]] forKeys:@[@"title", @"description"]];
    
    NSArray *defaultTweetData = [[NSArray alloc] initWithObjects:@"", nil];
    NSArray *defaultTweetNumberOfLines = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], nil];
    
    NSDictionary *defaultDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:1], @"selectedDuration", @"", @"selectedAccountIdentifier", defaultTimelineData, @"timelineData", defaultTimelineNumberOfLines, @"timelineNumberOfLines", defaultTweetData, @"tweetData", defaultTweetNumberOfLines, @"tweetNumberOfLines", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultDefaults];
    
    WriterTableViewController *writer = [[WriterTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:writer];
    [navigation.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navigation.navigationBar setTranslucent:NO];
    self.window.rootViewController = navigation;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53146108-1"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    NSLog(@"shouldSaveApplicationState");
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    NSLog(@"shouldRestoreApplicationState");
    return YES;
}
*/
 
@end
