//
//  MainViewController.m
//  probmxmag
//
//  Created by Aleksey Ivanov on 28.10.13.
//  Copyright (c) 2013 Aleksey Ivanov. All rights reserved.
//

#import "MainViewController.h"
#import "IssueCell.h"
#import "ContentManager.h"
#import "Reachability.h"
//SDWebImage
#import "UIImageView+WebCache.h"
#import "ReaderViewController.h"
#import "AppDelegate.h"
#import "TOWebViewController.h"

#import <Parse/Parse.h>

#define PublisherErrorMessage @"Can't get issue list from server!"

#define TITLE_LOADING @"Loading..."
#define free_subscribe_button @"Free subscription"
#define restore_subscription_button @"Restore subscription"
#define delete_issues_button @"Delete all issues"
#define alert_notReach @"Bad internet connection!"
#define alert_WWAN @"You are using cellular connection, so downloading new issue may cost some money, it depends of your operator. Continue?"
#define alert_subscribe_success @"You are successfully subscribed!"

#define CacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@class MFDocumentManager;

@interface MainViewController () <ReaderViewControllerDelegate,ContentManagerDelegate,StoreManagerDelegate>{
    UIInterfaceOrientation _lastOrientation;
}

@property (readonly)BOOL isIpad;
@property (readonly)BOOL isIos7;
@property (readonly)BOOL isRetina;
@property (readonly)BOOL isPortrait;


@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_lastOrientation !=[UIApplication sharedApplication].statusBarOrientation) {
        [self loadData];
    }
    _lastOrientation = [UIApplication sharedApplication].statusBarOrientation ;
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [ContentManager sharedManager].delegate = self;
    [IssueDownloader sharedManager].delegate = self;
    [StoreManager sharedManager].delegate = self;
    
    // set settings bar button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(changeSettings)];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
    
    //set refresh button
    UIBarButtonItem *refreshButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(loadData)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self.collectionView setHidden:YES];

   // [self loadData];
}

#pragma mark - Properties

-(BOOL)isIpad{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
-(BOOL)isPortrait{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

-(BOOL)isIos7{
    return [[[UIDevice currentDevice] systemVersion]floatValue]>= 7.0;
}

-(BOOL)isRetina{
    return [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0);
    
}

#pragma mark -

-(void)loadData{
    //self.navigationItem.title = TITLE_LOADING;
    [self.collectionView setHidden:YES];
    [[ContentManager sharedManager] tryToLoadFromRemoteFile];
}

#pragma mark - ContentManager Delegation methods
-(void)didLoadContent:(BOOL)success{
    [self.refreshControl endRefreshing];
    if (success) {
        [self showContent];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:PublisherErrorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}
-(void)showContent {
    //self.navigationItem.title = [ContentManager sharedManager].magazineTitle;
    [self.collectionView reloadData];
    [self.collectionView setHidden:NO];
}

#pragma mark - Settings button pressed
-(void)changeSettings{
    //TODO
   
    NSArray *buttons = @[free_subscribe_button,restore_subscription_button, delete_issues_button];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *buttonTitle in buttons) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];
}



#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [ContentManager sharedManager].issues.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IssueCell *cell=(IssueCell*)[cv dequeueReusableCellWithReuseIdentifier:@"IssueCell" forIndexPath:indexPath];
    cell.backgroundColor =[UIColor clearColor];
    
    //set shadow on cell.imageview
    [self setShadow:cell.imageView];
    
    NKLibrary *nkLib=[NKLibrary sharedLibrary];
    
    NKIssue *issue=[nkLib issueWithName:[[ContentManager sharedManager] nameOfIssueAtIndex:indexPath.row]];
    [cell updateCellInformationWithStatus:issue.status];
    
    NSString *titleOfIssue=[[ContentManager sharedManager] titleOfIssueAtIndex:indexPath.row];
    cell.issueTitle.text = titleOfIssue;
    NSString *description =[[ContentManager sharedManager] issueDescriptionAtIndex:indexPath.row];
    description = [description stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    cell.textView.backgroundColor = [UIColor clearColor];
    cell.textView.text = description;
    
    [cell.downloadOrShowButton setTag:indexPath.row];
    [cell.downloadOrShowButton addTarget:self action:@selector(cellButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [cell.delButton setTag:indexPath.row];
    
    [cell.delButton addTarget:self action:@selector(delButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //cover image
    [cell.activityIndicator startAnimating];
    [cell.imageView setTag:indexPath.row];
    
    NSURL *coverURL = [[ContentManager sharedManager] coverUrlOfIssueAtIndex:indexPath.row isRetina:self.isRetina];
    
    [cell.imageView setImageWithURL:coverURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (error) {
            NSLog(@"error to set image %@ from url %@",error,coverURL);
        }
        [cell.activityIndicator stopAnimating];
        
    }];
    if (issue.status == NKIssueContentStatusDownloading) {
        [cell.circularProgressView setAlpha:1.0];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (self.isPortrait && self.isIpad)
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    if (!self.isPortrait && self.isIpad) {
        return UIEdgeInsetsMake(10, 80, 10, 80);;
    }
    return UIEdgeInsetsMake(17, 0, 17, 0);
}


#pragma mark - Slider
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    SliderView *sliderView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                withReuseIdentifier:@"sliderView"
                                                                       forIndexPath:indexPath];
    [sliderView setHidden:NO];
    [sliderView.pageControl setNumberOfPages:[ContentManager sharedManager].slides.count];
    [sliderView.pageControl setCenter:CGPointMake(sliderView.center.x, sliderView.pageControl.center.y)];
    
    [self setScrollViewSize:sliderView.scrollView withPages:[ContentManager sharedManager].slides.count];
    
    [self loadSlideImagesToSliderScrollView:sliderView.scrollView];
   
    //scroll to first slide
    CGRect visibleFrame = CGRectMake(0, 0, sliderView.scrollView.frame.size.width , sliderView.scrollView.frame.size.height);
    [sliderView.scrollView scrollRectToVisible:visibleFrame animated:YES];
    
    return sliderView;
}
#pragma mark - UIButton cell Action
-(void)cellButtonPressed:(id)sender{
    int row = (int)[sender tag];
    [self showOrDownloadIssueAtIndex:row];
}

#pragma mark - del button action
-(void)delButtonPressed:(id)sender {
    int row = (int)[sender tag];
    [[ContentManager sharedManager] removeIssueAtIndex:row];

    IssueCell* tile = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[[ContentManager sharedManager] nameOfIssueAtIndex:row]];
   
    [tile updateCellInformationWithStatus:nkIssue.status];
}

#pragma mark - UICollectionViewDelegate
-(void)showOrDownloadIssueAtIndex:(int)index{
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[[ContentManager sharedManager] nameOfIssueAtIndex:index]];

    if(nkIssue.status==NKIssueContentStatusAvailable) {
        //open issue in pdf reader
        [self openPDF:nkIssue];
        
    } else if(nkIssue.status==NKIssueContentStatusNone) {
        //download issue
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        if (netStatus == NotReachable) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:alert_notReach delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            //[self downloadIssueAtIndex:index];
        }else if (netStatus == ReachableViaWiFi)
        {
            [self downloadIssueAtIndex:index];
        }else if (netStatus == ReachableViaWWAN){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:alert_WWAN delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            alert.tag = index;
            [alert show];
        }
    }
    else if(nkIssue.status == NKIssueContentStatusDownloading){
        //cancel downloading
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [nkLib removeIssue:nkIssue];
        
        [[ContentManager sharedManager] addIssuesInNewsstandLibrary];
        IssueCell* tile = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [tile updateCellInformationWithStatus:NKIssueContentStatusNone];
    }
}

#pragma mark -
-(void)downloadIssueAtIndex:(NSInteger)index {

    [[IssueDownloader sharedManager] downloadIsssueAtIndex:index];
    IssueCell* tile = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [tile.circularProgressView setAlpha:1.0];
    [tile.circularProgressView startSpinProgressBackgroundLayer];
    [tile updateCellInformationWithStatus:NKIssueContentStatusDownloading];
}

#pragma mark - NewsstandDownloaderDelegate methods

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    
    int tileIndex = [[dnl.userInfo objectForKey:@"index"] intValue];
    IssueCell* cell = (IssueCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:tileIndex inSection:0]];
    
    cell.circularProgressView.progress = 1.f*totalBytesWritten/expectedTotalBytes;
    [cell.imageView setAlpha:0.5f+0.5f*totalBytesWritten/expectedTotalBytes];
    [cell updateCellInformationWithStatus:NKIssueContentStatusDownloading];
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    
    if ([[UIApplication sharedApplication]applicationState]==UIApplicationStateActive) {
        [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }else{
        NSLog(@"App is backgrounded");
    }
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    
    [self.collectionView reloadData];
}
#pragma mark - IssueCellDelegate

-(void)trashContent
{
    [[ContentManager sharedManager] removeAllIssues];
    [self.collectionView reloadData];
}

#pragma mark - StoreManagerDelegate
-(void)subscriptionCompletedWith:(BOOL)success
{
    NSLog(@"subscriptionCompletedWith %@",success ? @"YES":@"NO");
    if (success) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Thanks"
                                                      message:alert_subscribe_success
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];

        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Subscription failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}
#pragma mark - Open in PDF reader
-(void)openPDF:(NKIssue*)issue{
    [[NKLibrary sharedLibrary] setCurrentlyReadingIssue:issue];

    NSString *documentName=[issue.name stringByAppendingString:@".pdf"];
    NSString* resourceFolder = [issue.contentURL path];
    NSString *filePath = [resourceFolder stringByAppendingString:[NSString stringWithFormat:@"/%@",documentName]];

    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:@""];
    if (document != nil)
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:readerViewController];
        
		[self presentViewController:navigationController animated:YES completion:NULL];

        //was[self.navigationController presentViewController:readerViewController animated:YES completion:nil];
    }
}

#pragma mark- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        switch (buttonIndex) {
            case 0:
            case 1:
            {
                //subscribe to magazine
                if ([[StoreManager sharedManager] isSubscribed]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks" message:alert_subscribe_success delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }else{
                    NSString *subscriptionID = [[ContentManager sharedManager] freeSubscriptionProductIdFromSlides];
                    [[StoreManager sharedManager] subscribeToMagazineWithProductID:subscriptionID];
                }
            }
                break;
            case 2:
            {
                //remove all content
                [self trashContent];
            }
                break;
            default:
                break;
        }
}



#pragma mark -Slider View methods
-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
}

-(void)loadSlideImagesToSliderScrollView:(UIScrollView*)scrollview{
    //remove all subviews
    for (UIView *subview in scrollview.subviews) {
        if([subview isKindOfClass:[UIImageView class]] || [subview isKindOfClass:[UIActivityIndicatorView class]])
        [subview removeFromSuperview];
    }
    for (int i=0;i<[ContentManager sharedManager].slides.count;i++) {
       
        CGRect frame = scrollview.bounds;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0f;
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        
        [scrollview addSubview:imageView];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:imageView.center];
        [spinner setHidesWhenStopped:YES];
        [scrollview addSubview:spinner];
        NSString *imageUrlStr = [[ContentManager sharedManager] slideImageLinkAtIndex:i
                                                                             isRetina:self.isRetina
                                                                isPortraitOrientation:self.isPortrait];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [spinner startAnimating];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrlStr]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             [spinner stopAnimating];
                         }];
        
        //add gesture recognizer at slider image view
        UITapGestureRecognizer *tapOnSlider = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleSlideTap:)];
        tapOnSlider.numberOfTapsRequired = 1;
        tapOnSlider.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tapOnSlider];
    }
}

-(void)setShadow:(UIView*)view{
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowOffset = CGSizeMake(3,3);
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
}
#pragma mark - HandleSlideTap
-(void)handleSlideTap:(UITapGestureRecognizer*)tapGestureRecognizer{
    NSInteger slideNmbr = tapGestureRecognizer.view.tag;
    NSString* actionIdentifier = [[ContentManager sharedManager] slideActionIdentifierFromSlideActionAtIndex:slideNmbr];
    if (actionIdentifier) {
        if ([actionIdentifier isEqualToString:@"toWebBrowser"])
        {
            NSString *actionParameter =[[ContentManager sharedManager] slideActionParameterFromSlideActionAtIndex:slideNmbr];
            if (actionParameter) {
                TOWebViewController *webBrowser = [[TOWebViewController alloc]
                                                   initWithURL:[NSURL URLWithString:actionParameter]];
                webBrowser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webBrowser] animated:YES completion:nil];
            }
        }
        if ([actionIdentifier isEqualToString:@"subscribe"]) {
            NSString *actionParameter =[[ContentManager sharedManager] slideActionParameterFromSlideActionAtIndex:slideNmbr];
            [[StoreManager sharedManager] subscribeToMagazineWithProductID:actionParameter];
        }
    }
}



-(NSUInteger)supportedInterfaceOrientations
{
    if (self.isIpad) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.collectionView setHidden:YES];
    
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self showContent];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag >= 0) {
        if (buttonIndex ==1) {
            [self downloadIssueAtIndex:alertView.tag];
        }
    }
}
#pragma mark - ReaderViewControllerDelegate methods
-(void)dismissReaderViewController:(ReaderViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma - mark Did Receive Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
