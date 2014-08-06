//
//  ExternalLinkViewController.h
//  ADVNewsstand
//
//  Created by Juan Docal on 18.07.13.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h> 

@interface ExternalLinkPageViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIPageViewController* pageController;

@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic) NSURL* URL;

@end
