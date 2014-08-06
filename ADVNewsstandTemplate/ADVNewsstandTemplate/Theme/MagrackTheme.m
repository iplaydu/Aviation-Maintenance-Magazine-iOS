//
//  MagrackTheme.m
//  ADVNewsstandTemplate
//
//  Created by Tope Abayomi on 23/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "MagrackTheme.h"
#import "Utils.h"
#import "IssueCell.h"

@implementation MagrackTheme

-(NSString*)backButtonImage{
    return @"magrack-backButton";
}

-(NSString*)barButtonImage{
    return @"magrack-barButton";
}

-(UIColor*)viewBackgroundColor{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

-(UIImage*)navigationBackgroundImage{
    if([Utils OSVersionIs6AndBelow]){
        return [UIImage imageNamed:@"magrack-navigationBackground"];
    }
    else{
        return [UIImage imageNamed:@"magrack-navigationBackground-7"];
    }
}

-(UIColor*)navigationBarTintColor{
    return [self themeColor];
}

-(UIImage*)navigationShadowImage{
    return [Utils createGradientImageFromColor:[UIColor colorWithWhite:0.0 alpha:0.2] toColor:[UIColor colorWithWhite:0.0 alpha:0.0] withSize:CGSizeMake(1024, 4)];
}

-(NSString*)backgroundImage{
    return @"red-background";
}

-(NSString*)buttonImage{
    return @"magrack-button-orange";
}

-(NSString*)buttonImagePressed{
    return @"magrack-button-orange-pressed";
}

-(NSString*)cellBackgroundImage{
    return @"red-cellBackground";
}

-(NSString*)cellDividerImage{
    return @"red-cellDivider";
}

-(UIColor*)themeColor{

    return [UIColor colorWithRed:197.0/255 green:57.0/255 blue:57.0/255 alpha:1.0];
}

-(NSString*)cellNibName{
    return @"IssueCellMagrack";
}

-(CGSize)cellSize{

    return CGSizeMake(320, 200);
}

-(UIEdgeInsets)cellEdgeInsets{
    
    return UIEdgeInsetsMake(50, 0, 0, 0);
}

-(CGFloat)cellLineSpacing{
    return 10.0f;
}

-(CGFloat)cellItemSpacing{
    return 0.0f;
}

-(NSString*)fontName{
    
    return @"Avenir-Book";
}

-(NSString*)boldfontName{
    return @"Avenir-Black";
}

-(void)customizeCell:(id)theCell{
    
    IssueCell* cell = (IssueCell*)theCell;
    
    UIColor* color = [self themeColor];
    [cell.downloadProgress setProgressTintColor:color];
    
    [cell.issueTitleLabel setTextColor:color];
    [cell.issueTitleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20.0f]];
    
    [cell.actionLabel setTextColor:[UIColor grayColor]];
    [cell.actionLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:14.0f]];
    
    [cell.downloadProgress setAlpha:0.0];
    
}

-(CGFloat)headerHeight{
    return 300;
}

@end
