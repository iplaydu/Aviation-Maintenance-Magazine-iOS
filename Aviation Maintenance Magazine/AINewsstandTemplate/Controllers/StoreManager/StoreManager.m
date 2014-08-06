//
//  StoreManager.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 10.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0]



#import "StoreManager.h"

@implementation StoreManager

@synthesize purchasing, delegate;


+(StoreManager*)sharedManager{
    static StoreManager* __sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[StoreManager alloc] init];
    });
    return __sharedManager;
}

-(BOOL)isSubscribed
{
    id receipt = [[NSUserDefaults standardUserDefaults] objectForKey:SUBSCRIPTION_FREE_ITUNES_PRODUCT_ID];
    return (receipt != nil);
}

-(void)subscribeToMagazineWithProductID:(NSString*)productID
{
    if(purchasing == YES) {
        return;
    }
    purchasing=YES;
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
    productsRequest.delegate=self;
    [productsRequest start];
    
}

-(void)requestDidFinish:(SKRequest *)request {
    purchasing = NO;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    purchasing = NO;

}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    if (response.invalidProductIdentifiers.count>0) {
        NSLog(@"invalidProductIdentifiers %@",response.invalidProductIdentifiers);
    }
    for(SKProduct *product in response.products) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                [self errorWithTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self finishedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"Restored all completed transactions");

}

-(void)finishedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Finished transaction");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSLog(@"transaction.transactionIdentifier %@",transaction.transactionIdentifier);
    // save receipt
    [[NSUserDefaults standardUserDefaults] setObject:transaction.transactionIdentifier forKey:SUBSCRIPTION_FREE_ITUNES_PRODUCT_ID];
    // check receipt
    [self checkReceipt:transaction.transactionReceipt];
    
    [self.delegate subscriptionCompletedWith:YES];
}

-(void)errorWithTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"errorWithTransaction %@",transaction.error);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self.delegate subscriptionCompletedWith:NO];
}

-(void)checkReceipt:(NSData *)receipt {
    // save receipt
    NSString *receiptStorageFile = [DocumentsDirectory stringByAppendingPathComponent:@"receipts.plist"];
    NSMutableArray *receiptStorage = [[NSMutableArray alloc] initWithContentsOfFile:receiptStorageFile];
    if(!receiptStorage) {
        receiptStorage = [[NSMutableArray alloc] init];
    }
    [receiptStorage addObject:receipt];
    [receiptStorage writeToFile:receiptStorageFile atomically:YES];
}



@end
