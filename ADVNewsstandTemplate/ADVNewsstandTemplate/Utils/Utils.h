//
//  Utils.h
//  ADVNewsstand
//
//  Created by Tope Abayomi on 13/09/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(BOOL)OSVersionIs6AndBelow;

+ (UIImage*)createGradientImageFromColor:(UIColor *)startColor toColor:(UIColor *)endColor withSize:(CGSize)size ;
@end
