//
//  SliderView.h
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 08.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderView : UICollectionReusableView <UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIPageControl *pageControl;



@end
