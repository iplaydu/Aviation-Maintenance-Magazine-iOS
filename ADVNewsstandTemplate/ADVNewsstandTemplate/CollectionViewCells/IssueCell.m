//
//  IssueCellBase.m
//  ADVNewsstand
//
//  Created by Tope Abayomi on 24/09/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "IssueCell.h"
#import "ADVTheme.h"
#import "AppDelegate.h"


@interface IssueCell ()

@end


@implementation IssueCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.callToActionText = kDownloadCTA;
    }
    return self;
}

-(void)awakeFromNib{
    
    id<ADVTheme> theme = [AppDelegate instance].theme;
    
    [theme customizeCell:self];
}

-(void)updateCellInformationWithStatus
{
    NKIssueContentStatus status = self.issueInfo.nkIssue.status;
    if(status == NKIssueContentStatusAvailable) {
        
        [self.actionLabel setText:@"READ"];
        [self.actionLabel setAlpha:1.0];
        [self.actionImageView setAlpha:1.0];
        
        [self.downloadProgress setAlpha:0.0];
        
    } else {
        
        if(status==NKIssueContentStatusDownloading) {
            [self.downloadProgress setAlpha:1.0];
            [self.actionLabel setAlpha:0.0];
            [self.actionImageView setAlpha:0.0];
            
        } else {
            [self.downloadProgress setProgress:0.0];
            [self.downloadProgress setAlpha:0.0];
            
            [self.actionLabel setText:self.callToActionText];
            [self.actionLabel setAlpha:1.0];
            [self.actionImageView setAlpha:1.0];
        }
        
    }
}

-(void)displayProductInfo{
    
    IssueInfo* issueInfo = self.issueInfo;
    
    if(issueInfo.isPaidContent && issueInfo.product){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:issueInfo.product.priceLocale];
        
        
        if([issueInfo userHasSubscribedToIssue]){
            self.callToActionText = kDownloadCTA;
        }
        else{
            NSString* price = [numberFormatter stringFromNumber:issueInfo.product.price];
            self.callToActionText = [NSString stringWithFormat:@"%@ - %@", price, kBuyNowCTA];
        }
        
        
    }else{
        
        self.callToActionText = kDownloadCTA;
    }
    
    self.issueTitleLabel.text = issueInfo.title;
    self.actionLabel.text = self.callToActionText;
    self.actionLabel.alpha = 1.0;
    
    [self updateCellInformationWithStatus];
}


-(void)displayCoverImage:(UIImage *)image{
    [self.coverImageView setImage:image];
}


-(void)subscriptionCompleted{
    
    [self displayProductInfo];
}

-(void)updateProgress:(CGFloat)progress{
    
    self.downloadProgress.alpha = 1.0;
    self.downloadProgress.progress = progress;
    
    [self updateCellInformationWithStatus];
}


-(void)setIssueInfo:(IssueInfo *)issueInfo{
    
    _issueInfo = issueInfo;
    
    _issueInfo.delegate = self;
    
    [self displayProductInfo];
    
}
@end
