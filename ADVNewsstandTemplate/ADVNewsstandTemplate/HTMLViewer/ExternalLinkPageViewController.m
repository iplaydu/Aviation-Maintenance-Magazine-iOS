//
//  ExternalLinkViewController.m
//  ADVNewsstand
//
//  Created by Juan Docal on 18.07.13.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "ExternalLinkPageViewController.h"
#import "MagazineViewController.h"

@interface ExternalLinkPageViewController ()

@property (nonatomic, strong) UIToolbar* toolbar;

@property (nonatomic, assign) BOOL barsHidden;

@end

@implementation ExternalLinkPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.pageController = [[UIPageViewController alloc]
                           initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                           options:nil];
     
    self.pageController.view.frame = self.view.bounds;
    
    [self.view addSubview:self.pageController.view]; 
    
    if(!self.webView){
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 44;
        
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webView.frame = frame;
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
    }
     
    [self loadWebViewWithPageAtPath:self.URL];
    
    CGRect toolbarRect = self.view.bounds;
	toolbarRect.size.height = 44;
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(returnToIssuesListTappedInToolbar:)];
    self.toolbar.items = @[returnButton];
    self.barsHidden = NO;
    [self.view addSubview:self.toolbar]; 
}

- (void)loadWebViewWithPageAtPath:(NSURL*)urlPath { 
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlPath];
    [self.webView loadRequest:requestObj]; 
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

- (IBAction)returnToIssuesListTappedInToolbar:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
} 

@end
