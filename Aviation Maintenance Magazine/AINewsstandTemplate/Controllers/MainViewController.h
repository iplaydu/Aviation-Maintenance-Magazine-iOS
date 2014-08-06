//
//  MainViewController.h
//  probmxmag
//
//  Created by Aleksey Ivanov on 28.10.13.
//  Copyright (c) 2013 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderView.h"
#import "IssueDownloader.h"
#import "StoreManager.h"

@class MFDocumentManager;

@interface MainViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate,UIAlertViewDelegate,IssueDownloaderDelegate,StoreManagerDelegate,UIScrollViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowlayout;
@property UIRefreshControl *refreshControl;


@end
