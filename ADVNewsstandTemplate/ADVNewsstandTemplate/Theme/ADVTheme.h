//
//  ADVTheme.h
//  ADVNewsstandTemplate
//
//  Created by Tope Abayomi on 23/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADVTheme <NSObject>

-(NSString*)backButtonImage;
-(NSString*)barButtonImage;
-(UIColor*)viewBackgroundColor;
-(UIImage*)navigationBackgroundImage;
-(UIColor*)navigationBarTintColor;
-(UIImage*)navigationShadowImage;
-(NSString*)backgroundImage;
-(NSString*)buttonImage;
-(NSString*)buttonImagePressed;
-(NSString*)cellBackgroundImage;
-(NSString*)cellDividerImage;
-(UIColor*)themeColor;
-(NSString*)cellNibName;
-(CGSize)cellSize;
-(UIEdgeInsets)cellEdgeInsets;
-(CGFloat)cellLineSpacing;
-(CGFloat)cellItemSpacing;
-(NSString*)fontName;
-(NSString*)boldfontName;
-(CGFloat)headerHeight;

-(void)customizeCell:(id)cell;
@end
