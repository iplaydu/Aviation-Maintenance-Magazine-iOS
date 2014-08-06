//
//  AppDelegate.h
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsstandDownloader.h"
#import "StoreManager.h"
#import "Publisher.h"
#import "ADVTheme.h"
#import "Repository.h"

#define kSubscriptionReceiptId @"SubscriptionReceiptId"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NewsstandDownloader * newsstandDownloader;

@property (nonatomic, strong) StoreManager *storeManager;

@property (nonatomic, strong) Publisher *publisher;

@property (nonatomic, strong) id<ADVTheme> theme;

@property (nonatomic, strong) Repository* repository;

+(AppDelegate*)instance;

@end
