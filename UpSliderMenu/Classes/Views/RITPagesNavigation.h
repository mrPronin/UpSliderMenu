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
- (void)pagesNavigation:(RITPagesNavigation *)pagesNavigation currentPageDidChange:(NSUInteger)pageIndex;
@end

@interface RITPagesNavigation : UIScrollView <UIScrollViewDelegate>

/*
@property (assign, nonatomic) IBOutlet id<RITPagesNavigationDelegate> delegate;
@property (assign, nonatomic) IBOutlet id<RITPagesNavigationDataSource> dataSource;
*/

@property (weak, nonatomic) id<RITPagesNavigationDelegate> delegate;
@property (weak, nonatomic) id<RITPagesNavigationDataSource> dataSource;


//@property (assign, nonatomic) CGFloat horizontalPageOffset;
@property (assign, nonatomic) CGSize pageSize;
@property (assign, nonatomic) CGFloat animationOffsetRatio;
@property (assign, nonatomic) NSTimeInterval animationDuration;

- (void)reloadData;
- (RITPage *)dequeueReusablePageWithIdentifier:(NSString *)reuseIdentifier;

@end
