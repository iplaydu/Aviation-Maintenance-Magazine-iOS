//
//  IssueCell.h
//  probmxmag
//
//  Created by Aleksey Ivanov on 28.10.13.
//  Copyright (c) 2013 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import "FFCircularProgressView.h"
@interface IssueCell : UICollectionViewCell

@property (weak,nonatomic) IBOutlet UIImageView *imageView;
@property (weak,nonatomic) IBOutlet UITextView *textView;
@property (weak,nonatomic) IBOutlet UILabel *issueTitle;
@property (weak,nonatomic) IBOutlet UIButton *downloadOrShowButton;
@property IBOutlet UIButton *delButton;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet FFCircularProgressView *circularProgressView;

- (void) updateCellInformationWithStatus:(NKIssueContentStatus)status;

@end
