//
//  IssueCellHeader.m
//  ADVNewsstand
//
//  Created by Tope Abayomi on 17/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "IssueCellHeader.h"
#import "AppDelegate.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation IssueCellHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    

    id<ADVTheme> theme = [AppDelegate instance].theme;
    
    self.subscribeInfoLabel.textColor = [UIColor whiteColor];
    self.subscribeInfoLabel.font = [UIFont fontWithName:@"Avenir-Book" size:18.0f];
    
    [self.subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.subscribeButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0f];
    
    [self.subscribeButton addTarget:self action:@selector(subscribeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.shadowColor = [UIColor colorWithWhite:0.2f alpha:0.3f].CGColor;
    self.bgView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.bgView.layer.shadowOpacity = 1.0f;
    
    
    if(![Utils OSVersionIs6AndBelow]){
        
        self.subscribeContainer.opaque = NO;
        self.subscribeContainer.backgroundColor = [UIColor clearColor];

        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.subscribeContainer.bounds];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        toolbar.barTintColor = [theme themeColor];
        [self.subscribeContainer insertSubview:toolbar atIndex:0];
    }else{
        
        const CGFloat* components = CGColorGetComponents([theme themeColor].CGColor);
        self.subscribeContainer.backgroundColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.6];
    }
}

-(IBAction)subscribeButtonTapped:(id)sender{
    [self.delegate subscribeButtonTapped];
}


@end
