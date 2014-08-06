//
//  ReceiptCheck.h
//  Newsstand
//
//  Created by Carlo Vigiani on 29/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiptCheckDelegate;

@interface ReceiptCheck : NSObject<NSURLConnectionDelegate>

-(void)validateSubscriptionReceipt;

-(void)checkReceiptWithProductionMode:(BOOL)useProduction;

@property (nonatomic,retain) NSData *receiptData;

@property (nonatomic, assign) id<ReceiptCheckDelegate> delegate;

@property (nonatomic, strong) NSMutableData *receivedData;

@end

@protocol ReceiptCheckDelegate <NSObject>

-(void)receiptValidated:(BOOL)success;

@end
