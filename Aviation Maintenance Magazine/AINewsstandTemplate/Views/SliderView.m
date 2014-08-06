//
//  SliderView.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 08.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "SliderView.h"

@implementation SliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger currentPage = (NSInteger)floor((scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    self.pageControl.currentPage = currentPage;
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
