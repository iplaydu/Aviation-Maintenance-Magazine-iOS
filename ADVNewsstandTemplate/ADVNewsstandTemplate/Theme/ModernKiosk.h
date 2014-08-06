//
//  ModernKiosk.h
//  ADVNewsstand
//
//  Created by Tope Abayomi on 24/09/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADVTheme.h"

@interface ModernKiosk : NSObject <ADVTheme>

-(id)initWithThemeColor:(UIColor*)color;

@property (nonatomic, strong) UIColor* themeColor;

@property (nonatomic, strong) UIImage* roundedRectButtonImage;

@end
