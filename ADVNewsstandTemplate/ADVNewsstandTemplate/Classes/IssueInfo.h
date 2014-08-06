//
//  MagIssue.h
//  Baker
//
//  Created by Tope on 19/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#import <StoreKit/StoreKit.h>
#import "StoreManager.h"

@class Publisher;

@protocol IssueInfoDelegate;

@interface IssueInfo : NSObject <StoreManagerDelegate>

@property (nonatomic, strong) NSString* uniqueId;

@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong) NSString* publicationDate;

@property (nonatomic, strong) NSString* coverImageUrl;

@property (nonatomic, strong) NSString* contentUrl;

@property (nonatomic, strong) NSString* type;

@property (nonatomic, assign) BOOL isPaidContent;

@property (nonatomic, readonly) BOOL isFreeContent;

@property (nonatomic, strong) NSString* inAppPurchaseId;

@property (nonatomic, strong) NKIssue* nkIssue;

@property (nonatomic, strong) SKProduct* product;

@property (nonatomic, assign) id<IssueInfoDelegate> delegate;

+(NSArray*)loadIssuesFromConfigData:(NSArray*)data;

-(void)subscribeToIssue;

-(void)loadCoverImageFromPublisher:(Publisher*)publisher;

-(BOOL)userHasSubscribedToIssue;
@end


@protocol IssueInfoDelegate <NSObject>

-(void)subscriptionCompleted;

-(void)displayProductInfo;

-(void)displayCoverImage:(UIImage*)image;

@end
