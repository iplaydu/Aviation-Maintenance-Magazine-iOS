//
//  AppDelegate.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 10.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "AppDelegate.h"
#import "IssueDownloader.h"
#import "StoreManager.h"

#import <Parse/Parse.h>


@implementation AppDelegate 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //In-App-Purchase
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreManager sharedManager]];

    //Background downloading
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
        [asset downloadWithDelegate:[IssueDownloader sharedManager]];
    }
    //reset app icon badge
    if (!launchOptions) {
       [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    //Parse apn server implementation
    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_APP_KEY];
    
    // Let the device know we want to handle Newsstand push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound | UIRemoteNotificationTypeNewsstandContentAvailability];
    // For debugging - allow multiple pushes per day

#ifdef DEV_MODE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
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


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

@end
