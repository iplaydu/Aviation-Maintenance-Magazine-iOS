//
//  MagazineHTMLViewController.h
//  ADVNewsstand
//
//  Created by Tope Abayomi on 10/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssueInfo.h"

@interface MagazinePageViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPageViewController* pageController;

@property (nonatomic, strong) NSArray* htmlFiles;

@property (nonatomic, strong) IssueInfo* issueInfo;

@end
