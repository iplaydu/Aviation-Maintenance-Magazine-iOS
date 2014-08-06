//
//  ModernKiosk.m
//  ADVNewsstand
//
//  Created by Tope Abayomi on 24/09/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "ModernKiosk.h"
#import "Utils.h"
#import "IssueCell.h"

@implementation ModernKiosk

-(NSString*)backButtonImage{
    return nil;
}

-(NSString*)barButtonImage{
    return nil;
}

-(UIColor*)viewBackgroundColor{
    return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:0.93];
}

-(NSString*)navigationBackgroundImage{
    return nil;
}


-(UIColor*)navigationBarTintColor{
    return [UIColor colorWithRed:0.48 green:0.77 blue:0.66 alpha:1.0];
}

-(UIImage*)navigationShadowImage{
    return [Utils createGradientImageFromColor:[UIColor colorWithWhite:0.0 alpha:0.2] toColor:[UIColor colorWithWhite:0.0 alpha:0.0] withSize:CGSizeMake(1024, 4)];
}

-(NSString*)backgroundImage{
    return nil;
}

-(NSString*)cellBackgroundImage{
    return nil;
}

-(NSString*)cellDividerImage{
    return nil;
}

-(NSString*)buttonImage{
   return @"modernkiosk-button";
}

-(NSString*)buttonImagePressed{
    return @"modernkiosk-button";
}

-(UIColor*)themeColor{
    
    return [UIColor colorWithRed:0.49 green:0.76 blue:0.66 alpha:1.0];
}

-(NSString*)cellNibName{
    return @"IssueCellModernKiosk";
}

-(CGSize)cellSize{
    
    return CGSizeMake(300, 415);
}

-(UIEdgeInsets)cellEdgeInsets{
    
    return  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(10, 40, 10, 40) : UIEdgeInsetsMake(50, 0, 0, 0);
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
    
    if(!self.roundedRectButtonImage)
    {
        self.roundedRectButtonImage = [self createRoundedRectImageWithColor:[self themeColor] andSize:CGSizeMake(40, 40) andRadius:CGSizeMake(3, 3)];
    }
    
    UIImage* buttonImage = [self.roundedRectButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [cell.actionImageView setImage:buttonImage];
    
    
    [cell.issueTitleLabel setTextColor:[UIColor grayColor]];
    [cell.issueTitleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0f]];
    
    [cell.actionLabel setTextColor:[UIColor whiteColor]];
    [cell.actionLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f]];
    
    [cell.downloadProgress setAlpha:0.0];
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
}

-(CGFloat)headerHeight{
    return 300;
}

-(UIImage*)createRoundedRectImageWithColor:(UIColor*)color andSize:(CGSize)size andRadius:(CGSize)radius{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:fillRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:radius];
    [path addClip];
    
    [path fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
