//
//  RITMenuScrollViewController.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITMenuScrollViewController.h"
#import "RITPage.h"

const NSInteger pageCount = 20;
const CGFloat pageOffset = 5.f;

@interface RITMenuScrollViewController ()

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (assign, nonatomic) CGRect pageFrame;
@property (assign, nonatomic) CGRect selectionZoneFrame;
@property (assign, nonatomic) CGFloat contentMargin;
@property (strong, nonatomic) RITPage *selectedPage;

- (NSArray*)loadVisiblePages;
- (UIView*)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
- (NSArray*) getVisiblePagesWithContentOffset:(CGPoint) offset;
- (NSInteger) pageWithView:(UIView*) page andArray:(NSArray*) pages;

// RIT DEBUG
@property (strong, nonatomic) UIView *selectionView;
//RIT DEBUG

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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _pageFrame = CGRectMake(0, 0, 50, 50);
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    
    // RIT DEBUG
    _selectionView = [[UIView alloc] initWithFrame:self.selectionZoneFrame];
    _selectionView.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:_selectionView];
    // RIT DEBUG
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.scrollView.contentOffset = CGPointMake(100, 0);
    
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    
    
    _contentMargin = (pagesScrollViewSize.width - pageWidth) / 2;
    self.scrollView.contentSize = CGSizeMake(pageWidth * pageCount + _contentMargin * 2, pagesScrollViewSize.height);
    
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
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    CGFloat pageScrollViewWidth = CGRectGetWidth(_scrollView.frame);
    
    // Determine number of hidden pages for left and right sides
    CGFloat leftPagesCount = (offset.x - _contentMargin) / pageWidth;
    CGFloat rightPagesCount = (offset.x - _contentMargin + pageScrollViewWidth) / pageWidth;
    
    // Work out which pages you want to load
    NSInteger firstPage = floor(leftPagesCount);
    NSInteger lastPage = ceil(rightPagesCount) - 1;
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        
        RITPage *pageView = (RITPage *)[self loadPage:i];
        if (pageView) {
            
            [pages addObject:pageView];
        }
    }
    
    return pages;
}

- (NSArray*)loadVisiblePages
{
    // First, determine which page is currently visible
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    CGFloat pageScrollViewWidth = CGRectGetWidth(_scrollView.frame);
    
    // Determine number of hidden pages for left and right sides
    CGFloat leftPagesCount = (self.scrollView.contentOffset.x - _contentMargin) / pageWidth;
    CGFloat rightPagesCount = (self.scrollView.contentOffset.x - _contentMargin + pageScrollViewWidth) / pageWidth;
    
    // Work out which pages you want to load
    NSInteger firstPage = floor(leftPagesCount);
    NSInteger lastPage = ceil(rightPagesCount) - 1;
    
    NSMutableArray *visiblePages = [NSMutableArray array];
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        
        [self purgePage:i];
        
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        
        UIView *page = [self loadPage:i];
        
        if (page) {
            
            [visiblePages addObject:page];
        }
        
    }
    for (NSInteger i=lastPage+1; i<pageCount; i++) {
        
        [self purgePage:i];
        
    }
    
    return visiblePages;
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
        CGRect frame = _pageFrame;
        frame.origin.x = frame.size.width * page + _contentMargin;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, pageOffset, pageOffset);
        
        RITPage *newPageView = [[RITPage alloc] initWithFrame:frame andText:[NSString stringWithFormat:@"%02ld", (long)(page)]];
        
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
        pageView = newPageView;
    }
    return pageView;
}

- (void)purgePage:(NSInteger)page
{
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

- (RITPage*)currentPageWithOffset:(CGPoint)offsetPoint andPages:(NSArray*)pages
{
    RITPage *currentPage = nil;
    
    CGFloat minDistance = _scrollView.contentSize.width;
    CGFloat selectionMidX = CGRectGetMidX(self.selectionZoneFrame);
    
    for (RITPage *page in pages) {
        
        CGFloat pageMidX = CGRectGetMidX(page.frame);
        CGFloat distance = fabs(selectionMidX - pageMidX);
        if (distance < minDistance) {
            
            currentPage = page;
            minDistance = distance;
        }
    }
    
    return currentPage;
}

- (void) setSelectedPage:(RITPage *)selectedPage
{
    
    if (selectedPage == _selectedPage) {
        return;
    }
    
    if (self.selectedPage) {
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            _selectedPage.backgroundColor = [UIColor blueColor];
            _selectedPage.center = CGPointMake(_selectedPage.center.x, _selectedPage.center.y + pageOffset);
            
        } completion:nil];
    }
    _selectedPage = selectedPage;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _selectedPage.backgroundColor = [UIColor lightGrayColor];
        _selectedPage.center = CGPointMake(_selectedPage.center.x, _selectedPage.center.y - pageOffset);
        
    } completion:nil];
}

- (void) scrollToPage:(NSInteger) pageIndex
{
    
    if (pageIndex < 0 || pageIndex >= pageCount) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    UIView *page = [self loadPage:pageIndex];
    
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    CGFloat pageScrollViewWidth = CGRectGetWidth(_scrollView.frame);
    CGPoint contentOffset = CGPointMake(CGRectGetMinX(page.frame) - (pageScrollViewWidth - pageWidth) / 2 - pageOffset, 0);
    [self.scrollView setContentOffset:contentOffset animated:YES];
    
}

- (CGRect) selectionZoneFrame
{
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    CGFloat pageHeight = CGRectGetHeight(_pageFrame);
    CGFloat pageScrollViewWidth = CGRectGetWidth(_scrollView.frame);
    _selectionZoneFrame = CGRectMake(_scrollView.contentOffset.x + (pageScrollViewWidth - pageWidth) / 2, 0, pageWidth, pageHeight);
    return _selectionZoneFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    NSArray *pages = [self loadVisiblePages];
    RITPage *currentPage = [self currentPageWithOffset:self.scrollView.contentOffset andPages:pages];
    self.selectedPage = currentPage;
    //[self selectPage:currentPage];
    //NSLog(@"views: %@", pages);
    _selectionView.frame = self.selectionZoneFrame;
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    CGPoint point = *targetContentOffset;
    NSArray *array = [self getVisiblePagesWithContentOffset:point];
    
    UIView *currentView = [self currentPageWithOffset:point andPages:array];
    
    CGFloat pageWidth = CGRectGetWidth(_pageFrame);
    CGFloat pageScrollViewWidth = CGRectGetWidth(_scrollView.frame);
    point = CGPointMake(CGRectGetMinX(currentView.frame) - (pageScrollViewWidth - pageWidth) / 2 - pageOffset, 0);
    *targetContentOffset = point;
}

/*
 
 - (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
 {
 
 NSLog(@"scrollViewWillBeginDragging contentOffset: %f", scrollView.contentOffset.x);
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
*/

#pragma mark - Actions

- (void)scrollViewTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.scrollView];
    NSArray *pages = [self getVisiblePagesWithContentOffset:self.scrollView.contentOffset];
    CGRect frame;
    for (UIView *page in pages) {
        
        frame = page.frame;
        frame = CGRectInset(frame, -pageOffset, -pageOffset);
        if (!CGRectContainsPoint(frame, pointInView)) continue;
        NSInteger pageIndex = [self pageWithView:page andArray:self.pageViews];
        if (pageIndex == NSNotFound) return;
        [self scrollToPage:pageIndex];
        return;
    }
}

- (NSInteger) pageWithView:(UIView*) page andArray:(NSArray*) pages
{
    
    NSInteger index = NSNotFound;
    
    index = [pages indexOfObject:page];
    
    return index;
}

- (IBAction)actionScrollToPageButton:(UIButton *)sender {
    
    [self scrollToPage:15];
    
}
@end
