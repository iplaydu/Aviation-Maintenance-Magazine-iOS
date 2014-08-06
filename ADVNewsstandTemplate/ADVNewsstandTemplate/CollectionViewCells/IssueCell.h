//
//  IssueCellBase.h
//  ADVNewsstand
//
//  Created by Tope Abayomi on 24/09/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import "IssueInfo.h"
#import "StoreManager.h"

#define kDownloadCTA @"DOWNLOAD"
#define kBuyNowCTA @"BUY NOW"
#define kReadCTA @"READ"

@interface IssueCell : UICollectionViewCell <IssueInfoDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* bgImageView;

@property (nonatomic, weak) IBOutlet UIImageView* dividerImageView;

@property (nonatomic, weak) IBOutlet UIView* coverContainerView;

@property (nonatomic, weak) IBOutlet UIImageView* coverImageView;

@property (nonatomic, weak) IBOutlet UILabel* issueTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel* actionLabel;

@property (nonatomic, weak) IBOutlet UIImageView* actionImageView;

@property (nonatomic, weak) IBOutlet UIProgressView* downloadProgress;

@property (nonatomic, strong) IssueInfo* issueInfo;

@property (nonatomic, strong) NSString* callToActionText;

-(void)updateProgress:(CGFloat)progress;


@end
