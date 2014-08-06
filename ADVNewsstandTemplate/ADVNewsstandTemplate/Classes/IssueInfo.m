//
//  MagIssue.m
//  Baker
//
//  Created by Tope on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueInfo.h"
#import "AppDelegate.h"

@implementation IssueInfo

@synthesize isFreeContent = _isFreeContent;

+(NSArray*)loadIssuesFromConfigData:(NSArray*)data{
    
    NSMutableArray* issues = [NSMutableArray arrayWithCapacity:data.count];
    for (NSDictionary* item in data) {
        
        IssueInfo* info = [[IssueInfo alloc] init];
        
        info.uniqueId = item[@"uniqueId"];
        info.title = item[@"title"];
        info.publicationDate = item[@"date"];
        info.coverImageUrl = item[@"coverImageUrl"];
        info.contentUrl = item[@"contentUrl"];
        info.type = item[@"type"];
        
        info.inAppPurchaseId = item[@"in-app-purchase-id"];
        info.isPaidContent = info.inAppPurchaseId != nil;
            
        [issues addObject:info];
        
    }
    return issues;

}

-(BOOL)isFreeContent{
    return !self.isPaidContent;
}

-(BOOL)userHasSubscribedToIssue{
    if(self.isFreeContent){
        return YES;
    }else{
        
        StoreManager* storeManager = [AppDelegate instance].storeManager;
        return [storeManager isSubscribedToContent:self.inAppPurchaseId];
    }
}

-(void)subscribeToIssue{
    
    StoreManager* storeManager = [AppDelegate instance].storeManager;
    storeManager.delegate  = self;
    [storeManager subscribeToProduct:self.product];

}

-(void)didFetchProductInfos:(NSArray *)products withSuccess:(BOOL)success{
    
}

-(void)subscriptionCompletedWith:(BOOL)success forInAppPurchaseId:(NSString *)inAppPurchaseId{
    
    StoreManager* storeManager = [AppDelegate instance].storeManager;
    storeManager.delegate = nil;
    
    if(success && [inAppPurchaseId isEqualToString:self.inAppPurchaseId]){
        
        [self.delegate subscriptionCompleted];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully subscribed to this issue. Please select it to start your download" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }  
}

-(void)loadCoverImageFromPublisher:(id)publisher{
    
    UIImage* coverImage = [publisher coverImageForIssueAtIndex:[publisher indexOfIssue:self]];
    if(coverImage)
    {
        [self.delegate displayCoverImage:coverImage];
    }
    else {
        
        [self.delegate displayCoverImage:nil];
        
        int index = [publisher indexOfIssue:self];
        [publisher setCoverOfIssueAtIndex:index completionBlock:^(UIImage *img) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate displayCoverImage:img];
            });
        }];
    }

}

-(void)didRestoreAllPurchases{
    
}


@end
