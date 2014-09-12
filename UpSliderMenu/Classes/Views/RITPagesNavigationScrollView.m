//
//  RITPagesNavigationScrollView.m
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPagesNavigationScrollView.h"

@implementation RITPagesNavigationScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self constructScrollView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[super initWithCoder:aDecoder]))
    {
        [self constructScrollView];
    }
    return self;
}

- (void)constructScrollView
{
    self.backgroundColor = [UIColor clearColor];
}

@end
