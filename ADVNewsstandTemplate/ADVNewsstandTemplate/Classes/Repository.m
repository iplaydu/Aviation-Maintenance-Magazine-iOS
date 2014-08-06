//
//  Configuration.m
//  ADVNewsstand
//
//  Created by Tope Abayomi on 25/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#define kConfigFilename @"Configuration"
#define kCachedConfigFilename @"cachedConfig.json"
#define kConfigLocationKey @"IssueConfigurationLocation"
#define kSubscriptionTextKey @"SubscriptionText"
#define kInProductionModeKey @"InProductionMode"
#define kITunesSharedSecret @"iTunesSharedSecret"
#define kImplementSubscriptionPurchases @"ImplementSubscriptionPurchases"

#define CacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#import "Repository.h"
#import "Reachability.h"

@interface Repository ()

@property (nonatomic, strong) NSDictionary* config;

@end

@implementation Repository

-(NSArray *)magazineIssues{
    
    if(self.config){
        
        return self.config[@"issues"];
    }
    
    return [NSArray array];
}

-(NSString*)inAppPurchaseSubscriptionId{
    
    if(self.config){
        
        return self.config[@"in-app-purchase-id"];
    }
    
    return nil;
}

-(NSArray*)allInAppPurchases{
    
    NSArray* magazineIssues = [self magazineIssues];
    NSMutableArray* ids = [NSMutableArray array];
    
    for (NSDictionary* issue in magazineIssues) {
        NSString* inAppPurchaseId = issue[@"in-app-purchase-id"];
        
        if(inAppPurchaseId){
            [ids addObject:inAppPurchaseId];
        }
    }
    
    
    if(self.inAppPurchaseSubscriptionId){
        [ids addObject:self.inAppPurchaseSubscriptionId];
    }

    return [NSArray arrayWithArray:ids];

}

-(void)loadMagazineConfigurationFromServer{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        
        NSString* cachedIssuesName = [CacheDirectory stringByAppendingPathComponent:kCachedConfigFilename];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cachedIssuesName];
        
        if (fileExists) {
            
            self.config = [NSDictionary dictionaryWithContentsOfFile:cachedIssuesName];
        }
        
        [self.delegate didLoadMagazineConfigurationFromServerWithSuccess:fileExists];
        
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       
                       
                       NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self getIssuesLocation]]];
                       NSError* error;
                       
                       NSDictionary* jsonData =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                       
                       self.config = jsonData;
                       
                       if(!jsonData) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                              
                               [self.delegate didLoadMagazineConfigurationFromServerWithSuccess:NO];
                           });
                           
                       } else {
                           
                           NSString* cachedIssuesName = [CacheDirectory stringByAppendingPathComponent:kCachedConfigFilename];
                           
                           [jsonData writeToFile:cachedIssuesName atomically:YES];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               [self.delegate didLoadMagazineConfigurationFromServerWithSuccess:YES];
                           });
                       }
                   });
    }

}

-(NSString*)getIssuesLocation{
    
    return [self getTextFromConfigurationWithKey:kConfigLocationKey];
    
}

-(NSString*)getSubscriptionText{
    
    return [self getTextFromConfigurationWithKey:kSubscriptionTextKey];
}

-(NSString*)iTunesSharedSecret{
    return [self getTextFromConfigurationWithKey:kITunesSharedSecret];
}

-(BOOL)implementSubscriptionPurchases{
   return  [[self getTextFromConfigurationWithKey:kImplementSubscriptionPurchases] boolValue];
}

-(id)getTextFromConfigurationWithKey:(NSString*)key{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:kConfigFilename ofType:@"plist"];
    
    NSDictionary* config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return config[key];
    
}

-(NSDictionary*)loadHTMLMagazineDataWithPath:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {

        NSError* error;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
        NSMutableArray* contents = [NSMutableArray array];
        
        for (NSString* filename in files) {
            
            NSRange range = [filename rangeOfString:@".htm"];
           
            if (range.location != NSNotFound) {
                [contents addObject:filename];
            }
        }
        
        NSDictionary* data = @{@"contents": contents};
        
        return data;
    
    }
    else{
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Data" message:@"Cannot load magazine pages from the specified location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return nil;
    }
}

@end
