//
//  StoreManager.h
//  Baker
//
//  Created by Tope on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ReceiptCheck.h"

@protocol StoreManagerDelegate;

@interface StoreManager : NSObject <SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL purchasing;

-(void)fetchProductInfoWithIds:(NSSet*)productIds;

-(void)subscribeToProduct:(SKProduct*)SKProduct;

-(BOOL)isSubscribedToContent:(NSString*)inAppPurchaseId;

-(void)restorePurchases;

@property (nonatomic, assign) id<StoreManagerDelegate> delegate;

@end


@protocol StoreManagerDelegate <NSObject>

-(void)didFetchProductInfos:(NSArray*)products withSuccess:(BOOL)success;

-(void)subscriptionCompletedWith:(BOOL)success forInAppPurchaseId:(NSString*)inAppPurchaseId;

-(void)didRestoreAllPurchases;

@end