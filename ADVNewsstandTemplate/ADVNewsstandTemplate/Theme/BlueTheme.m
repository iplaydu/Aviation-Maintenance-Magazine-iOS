//
//  Theme.m
//  ADVNewsstandTemplate
//
//  Created by Tope Abayomi on 23/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "BlueTheme.h"
#import "Utils.h"
#import "IssueCell.h"

@implementation BlueTheme

-(NSString*)backButtonImage{
    return @"blue-back";
}

-(NSString*)barButtonImage{
    return @"blue-barButton";
}

-(UIColor*)viewBackgroundColor{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

-(UIImage*)navigationBackgroundImage{
    if([Utils OSVersionIs6AndBelow]){
        return [UIImage imageNamed:@"blue-navigationBackground"];
    }
    else{
        return [UIImage imageNamed:@"blue-navigationBackground-7"];
    }
}

-(UIColor*)navigationBarTintColor{
    return [self themeColor];
}

-(UIImage*)navigationShadowImage{
    return nil;
}

-(NSString*)backgroundImage{
    return @"blue-background";
}

-(NSString*)buttonImage{
    return @"blue-button-orange";
}

-(NSString*)buttonImagePressed{
    return @"blue-button-orange-pressed";
}

-(NSString*)cellBackgroundImage{
    return @"blue-cellBackground";
}

-(NSString*)cellDividerImage{
    return @"blue-cellDivider";
}

-(UIColor*)themeColor{

    return [UIColor colorWithRed:18.0/255 green:132.0/255 blue:195.0/255 alpha:1.0];
    
}

-(NSString*)cellNibName{
    return @"IssueCell";
}

-(CGSize)cellSize{
    return CGSizeMake(300, 471);
}

-(UIEdgeInsets)cellEdgeInsets{
    return  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(50, 50, 50, 50) : UIEdgeInsetsMake(50, 0, 0, 0);
}

-(CGFloat)cellLineSpacing{
    return 10.0f;
}

-(CGFloat)cellItemSpacing{
    return 10.0f;
}

-(NSString*)fontName{

    return @"Avenir-Book";
}

-(NSString*)boldfontName{
    return @"Avenir-Black";
}

-(void)customizeCell:(id)theCell{
 
    IssueCell* cell = (IssueCell*)theCell;
    
    [cell.bgImageView setImage:[UIImage imageNamed:[self cellBackgroundImage]]];
    [cell.dividerImageView setImage:[UIImage imageNamed:[self cellDividerImage]]];
    
    UIImage* buttonImage = [[UIImage imageNamed:[self buttonImage]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [cell.actionImageView setImage:buttonImage];
    
    cell.coverContainerView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
    cell.coverContainerView.layer.borderWidth = 3.0;
    
    UIColor* color = [self themeColor];
    [cell.downloadProgress setProgressTintColor:color];
    [cell.issueTitleLabel setTextColor:color];
    [cell.issueTitleLabel setFont:[UIFont fontWithName:[self boldfontName] size:19.0f]];
    
    [cell.actionLabel setFont:[UIFont fontWithName:[self boldfontName] size:15.0f]];
    
}

-(CGFloat)headerHeight{
    return 300;
}

@end
