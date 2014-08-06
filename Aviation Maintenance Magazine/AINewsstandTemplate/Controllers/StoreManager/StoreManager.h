//
//  StoreManager.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 10.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StoreManagerDelegate;

@interface StoreManager : NSObject <SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>



@property (nonatomic, assign) BOOL purchasing;
@property (nonatomic, assign) id<StoreManagerDelegate> delegate;

+(StoreManager*)sharedManager;

-(void)subscribeToMagazineWithProductID:(NSString*)productID;
-(BOOL)isSubscribed;

@end

@protocol StoreManagerDelegate <NSObject>

-(void)subscriptionCompletedWith:(BOOL)success;

@end