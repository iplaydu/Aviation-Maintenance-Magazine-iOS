//
//  ViewController.h
//  ADVNewsstandTemplate
//
//  Created by Tope on 07/03/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ReaderViewController.h"
#import "IssueCellHeader.h"
#import "ReceiptCheck.h"
#import "GAITrackedViewController.h"

@interface IssuesGridViewController : GAITrackedViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewsstandDownloaderDelegate, PublisherDelegate, StoreManagerDelegate, ReaderViewControllerDelegate, IssueCellHeaderDelegate, ReceiptCheckDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) Publisher* publisher;

@property (nonatomic, strong) Repository* repository;

@property (nonatomic, strong) StoreManager* storeManager;

@property (nonatomic, strong) id<ADVTheme> theme;

-(void)didLoadIssuesWithSuccess:(BOOL)success;

-(void)didFetchProductInfos:(NSArray *)products withSuccess:(BOOL)success;

-(void)subscribeButtonTapped;

-(void)subscriptionCompletedWith:(BOOL)success forInAppPurchaseId:(NSString *)inAppPurchaseId;

@end

