//
//  MagazineViewController.m
//  ADVNewsstand
//
//  Created by Tope Abayomi on 10/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "MagazineViewController.h"
#import "ExternalLinkPageViewController.h" 
#import "MagazinePageViewController.h"

@interface MagazineViewController ()

- (void)loadWebViewWithPageAtPath:(NSString*)filePath; 

@end

@implementation MagazineViewController

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
    
    if(!self.webView){
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webView.delegate = self; //JUAN
        [self.view addSubview:self.webView];
    }
    
    [self loadWebViewWithPageAtPath:self.path]; 
}

- (void)loadWebViewWithPageAtPath:(NSString*)filePath {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //NSLog(@"• Loading: book/%@", [[NSFileManager defaultManager] displayNameAtPath:filePath]);
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { //JUAN 
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {   
        
        NSString *clickedURL = [[NSString alloc] initWithFormat:@"%@",request.URL];
        
        NSString *linkType = [clickedURL substringWithRange:NSMakeRange(0, 4)];
        //NSLog(@"%@",linkType);
        
        if([linkType isEqual: @"file"]){
            NSRange rangeHtml = [clickedURL rangeOfString:@"/" options:NSBackwardsSearch]; 
            NSString *html = [clickedURL substringWithRange:NSMakeRange(rangeHtml.location+1,[clickedURL length]-(rangeHtml.location+1))];
            //NSLog(@"%@",html);
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:html forKey:@"HTML"];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"internalScreen" object:nil userInfo:dictionary];
        }
        else{
            ExternalLinkPageViewController * pageViewController = [[ExternalLinkPageViewController alloc] init];
            pageViewController.URL = request.URL;
            [self presentViewController:pageViewController animated:YES completion:nil];
        }
        
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
