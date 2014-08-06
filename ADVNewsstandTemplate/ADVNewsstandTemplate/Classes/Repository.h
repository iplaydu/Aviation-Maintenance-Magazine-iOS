//
//  Configuration.h
//  ADVNewsstand
//
//  Created by Tope Abayomi on 25/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#define kPublisherDidUpdateNotification  @"PublisherDidUpdate"
#define kPublisherFailedUpdateNotification  @"PublisherFailedUpdate"


#import <Foundation/Foundation.h>

@protocol RepositoryDelegate;

@interface Repository : NSObject

@property (nonatomic, assign) id<RepositoryDelegate> delegate;

-(void)loadMagazineConfigurationFromServer;

-(NSArray*)magazineIssues;

-(NSString*)inAppPurchaseSubscriptionId;

-(NSArray*)allInAppPurchases;

-(NSDictionary*)loadHTMLMagazineDataWithPath:(NSString*)path;

-(NSString*)getSubscriptionText;

-(NSString*)iTunesSharedSecret;

-(BOOL)implementSubscriptionPurchases;


@end


@protocol RepositoryDelegate <NSObject>

-(void)didLoadMagazineConfigurationFromServerWithSuccess:(BOOL)success;

@end