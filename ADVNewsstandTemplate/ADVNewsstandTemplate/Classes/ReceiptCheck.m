//
//  ReceiptCheck.m
//  Newsstand
//
//  Created by Carlo Vigiani on 29/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "ReceiptCheck.h"
#import "NSString+Base64.h"
#import "AppDelegate.h"

@implementation ReceiptCheck

-(void)validateSubscriptionReceipt{
    
    self.receiptData = [[NSUserDefaults standardUserDefaults] dataForKey:kSubscriptionReceiptId];
    
    if(!self.receiptData){
        [self.delegate receiptValidated:NO];
    }
    else{
        [self checkReceiptWithProductionMode:YES];
    }
}

- (void)checkReceiptWithProductionMode:(BOOL)useProduction {
    // verifies receipt with Apple
    NSError *jsonError = nil;
    NSString *receiptBase64 = [NSString base64StringFromData:self.receiptData length:[self.receiptData length]];
    
    Repository* repository = [[AppDelegate instance] repository];
    
    NSString* sharedSecret = [repository iTunesSharedSecret];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                receiptBase64, @"receipt-data",
                                                                sharedSecret, @"password",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError
                        ];
    NSLog(@"JSON: %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSString* productionModeURL = @"https://buy.itunes.apple.com/verifyReceipt";
    NSString* developmentModeURL = @"https://sandbox.itunes.apple.com/verifyReceipt";
    
    NSString* itunesUrl = useProduction ? productionModeURL : developmentModeURL;
    
    NSURL *requestURL = [NSURL URLWithString:itunesUrl];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if(conn) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        
        [self.delegate receiptValidated:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Cannot transmit receipt data. %@",[error localizedDescription]);
    
    [self.delegate receiptValidated:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *response = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Receipt has been validated: %@",response);
    NSData* data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    NSString* status = [[NSString alloc]initWithFormat:@"%@",[json objectForKey:@"status"]];
    
    NSLog(@"Status is: %@ iTunes response: %@", status, response);
    if([status isEqualToString:@"21007"]){
        [self checkReceiptWithProductionMode:NO];
    }
    else if([status isEqualToString:@"0"]){
        [self.delegate receiptValidated:YES];
    }
    else{
        
        [self.delegate receiptValidated:NO];
        
        if([status isEqualToString:@"21000"]){
            NSLog(@"The App Store could not read the JSON object you provided.");
        }else if([status isEqualToString:@"21002"]){
            NSLog(@"The receipt could not be authenticated.");
        }else if([status isEqualToString:@"21004"]){
            NSLog(@"The shared secret you provided does not match the shared secret on file for your account.");
        }else if([status isEqualToString:@"21005"]){
            NSLog(@"The receipt server is not currently available");
        }else if([status isEqualToString:@"21006"]){
            NSLog(@"This receipt is valid but the subscription has expired.");
        }else if([status isEqualToString:@"21008"]){
            NSLog(@"This receipt is a production receipt, but it was sent to the sandbox service for verification");
        }
    }
}


@end
