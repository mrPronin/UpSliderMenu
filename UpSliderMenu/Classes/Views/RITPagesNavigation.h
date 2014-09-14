//
//  RITPagesNavigation.h
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITPage.h"

@class RITPagesNavigation;

@protocol RITPagesNavigationDataSource <NSObject>
@required
- (RITPage *)pagesNavigation:(RITPagesNavigation *)pagesNavigation pageAtIndex:(NSUInteger)pageIndex;
- (NSUInteger)numberOfPagesForPagesNavigation:(RITPagesNavigation *)pagesNavigation;
@end

@protocol RITPagesNavigationDelegate <UIScrollViewDelegate>
@optional
- (void)pagesNavigation:(RITPagesNavigation *)pagesNavigation tapOnPageWithIndex:(NSUInteger)pageIndex;
@end

@interface RITPagesNavigation : UIScrollView <UIScrollViewDelegate>

@property (assign, nonatomic) IBOutlet id<RITPagesNavigationDelegate> delegate;
@property (assign, nonatomic) IBOutlet id<RITPagesNavigationDataSource> dataSource;
//@property (assign, nonatomic) CGFloat horizontalPageOffset;
@property (assign, nonatomic) CGSize pageSize;

- (void)reloadData;
- (RITPage *)dequeueReusablePageWithIdentifier:(NSString *)reuseIdentifier;

@end
