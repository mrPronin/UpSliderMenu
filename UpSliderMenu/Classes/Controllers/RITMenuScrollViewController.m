//
//  RITMenuScrollViewController.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITMenuScrollViewController.h"
#import "RITPageThumbView.h"

const NSInteger pageCount = 20;

@interface RITMenuScrollViewController ()

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (assign, nonatomic) CGRect initialFrame;

- (void)loadVisiblePages;
- (UIView*)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
- (NSArray*) getVisiblePagesWithContentOffset:(CGPoint) offset;

@end

@implementation RITMenuScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _initialFrame = CGRectMake(0, 0, 50, 50);
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat pageWidth = _initialFrame.size.width;
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pageWidth * pageCount, pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (NSArray*) getVisiblePagesWithContentOffset:(CGPoint) offset
{
    NSMutableArray *pages = [NSMutableArray array];
    CGFloat pageWidth = _initialFrame.size.width;
    
    // Determine number of hidden pages for left and right sides
    CGFloat leftPagesCount = offset.x / pageWidth;
    CGFloat rightPagesCount = (offset.x + self.scrollView.frame.size.width) / pageWidth;
    
    // Work out which pages you want to load
    NSInteger firstPage = floor(leftPagesCount);
    NSInteger lastPage = ceil(rightPagesCount) - 1;
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        
        RITPageThumbView *pageView = (RITPageThumbView*)[self loadPage:i];
        if (pageView) {
            
            [pages addObject:pageView];
        }
    }
    
    return pages;
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = _initialFrame.size.width;
    //NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    //NSInteger page = 0;
    
    // Determine number of hidden pages for left and right sides
    CGFloat leftPagesCount = self.scrollView.contentOffset.x / pageWidth;
    CGFloat rightPagesCount = (self.scrollView.contentOffset.x + self.scrollView.frame.size.width) / pageWidth;
    
    // Work out which pages you want to load
    NSInteger firstPage = floor(leftPagesCount);
    NSInteger lastPage = ceil(rightPagesCount) - 1;
    
    // RIT DEBUG
    //NSLog(@"left: %.2f, right: %.2f, first: %d, last: %d", leftPagesCount, rightPagesCount, firstPage, lastPage);
    //NSLog(@"Page: %d, page width: %.0f, contentOffset: %@", page, pageWidth, NSStringFromCGPoint(self.scrollView.contentOffset));
    //NSLog(@"page width: %.0f, offset: %0.f, page: %d, calc: %.2f", pageWidth, self.scrollView.contentOffset.x, page, (self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    /*
    // load all pages
    for (NSInteger i = 0; i < pageCount; i++) {
        [self loadPage:i];
    }
    return;
    */
    // RIT DEBUG
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<pageCount; i++) {
        [self purgePage:i];
    }
}

- (UIView*)loadPage:(NSInteger)page
{
    
    if (page < 0 || page >= pageCount) {
        // If it's outside the range of what we have to display, then do nothing
        return nil;
    }
    
    // Load an individual page, first checking if you've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = _initialFrame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 5.0f, 5.0f);
        
        RITPageThumbView *newPageView = [[RITPageThumbView alloc] initWithFrame:frame andText:[NSString stringWithFormat:@"%02ld", (long)(page)]];
        
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
        pageView = newPageView;
    }
    return pageView;
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= pageCount) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    [self loadVisiblePages];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollViewWillBeginDragging contentOffset: %f", scrollView.contentOffset.x);
    NSLog(@"\n");
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    NSLog(@"scrollViewWillEndDragging contentOffset: %f", scrollView.contentOffset.x);
    CGPoint point = *targetContentOffset;
    NSLog(@"velocity: %@, %f", NSStringFromCGPoint(velocity), point.x);
    
    NSArray *array = [self getVisiblePagesWithContentOffset:point];
    NSLog(@"views: %@", array);
    NSLog(@"\n");
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    NSLog(@"scrollViewDidEndDragging contentOffset: %f", scrollView.contentOffset.x);
    NSLog(@"decelerate: %d", decelerate);
    NSLog(@"\n");
    
}

- (void) scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollViewDidScrollToTop contentOffset: %f", scrollView.contentOffset.x);
    NSLog(@"\n");
    
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollViewWillBeginDecelerating contentOffset: %f", scrollView.contentOffset.x);
    NSLog(@"\n");
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollViewDidEndDecelerating contentOffset: %f", scrollView.contentOffset.x);
    NSLog(@"\n");
    
}

@end
