//
//  RITPagesNavigation.m
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPagesNavigation.h"
#import "RITPageRecord.h"

@interface RITPagesNavigation ()

@property (strong, nonatomic) NSMutableSet* reusePool;
@property (strong, nonatomic) NSMutableArray* pageRecords;
@property (strong, nonatomic) NSMutableIndexSet* visiblePages;
@property (strong, nonatomic) RITPage *selectedPage;
@property (assign, nonatomic) CGRect selectionZoneFrame;
// RIT DEBUG
//@property (strong, nonatomic) UIView *selectionView;
//RIT DEBUG

@end

@implementation RITPagesNavigation {
    NSUInteger _pagesCount;
    CGFloat _contentMargin;
    id<RITPagesNavigationDelegate> _pagesNavigationDelegate;
    
    struct {
        unsigned pageAtIndex : 1;
        unsigned numberOfPagesForPagesNavigation : 1;
    } _dataSourceHas;
    
    struct {
        // RITPagesNavigationDelegate
        unsigned tapOnPageWithIndex : 1;
        unsigned currentPageDidChange : 1;
        
        // UIScrollViewDelegate
        unsigned scrollViewDidScroll : 1;
        unsigned scrollViewWillBeginDragging : 1;
        unsigned scrollViewDidEndDragging : 1;
        unsigned viewForZoomingInScrollView : 1;
        unsigned scrollViewWillBeginZooming : 1;
        unsigned scrollViewDidEndZooming : 1;
        unsigned scrollViewDidZoom : 1;
        unsigned scrollViewDidEndScrollingAnimation : 1;
        unsigned scrollViewWillBeginDecelerating : 1;
        unsigned scrollViewDidEndDecelerating : 1;
        unsigned scrollViewWillEndDragging : 1;
    } _delegateHas;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self propertyInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[super initWithCoder:aDecoder]))
    {
        [self propertyInitialization];
    }
    return self;
}

#pragma mark -
#pragma mark Public mothods

- (void)reloadData
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] _dataSource: %@", [self class], NSStringFromSelector(_cmd), _dataSource);
    // RIT DEBUG
    
    if (!_dataSource) return;
    _pagesCount = _dataSourceHas.numberOfPagesForPagesNavigation ?[_dataSource numberOfPagesForPagesNavigation:self] : 0;
    
    [self returnNonVisiblePagesToThePool:nil];
    [self setContentSize];
    [self generateWidthAndOffsetData];
    [self layoutPageViews];
}

- (RITPage *)dequeueReusablePageWithIdentifier:(NSString *)reuseIdentifier
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    RITPage* poolPage = nil;
    
    for (RITPage* currentPage in [self reusePool])
    {
        if ([currentPage.reuseIdentifier isEqualToString: reuseIdentifier])
        {
            poolPage = currentPage;
            break;
        }
    }
    
    if (poolPage)
    {
        [[self reusePool] removeObject: poolPage];
    }
    return poolPage;
}

#pragma mark -
#pragma mark Layout methods

- (void)layoutPageViews
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    CGFloat currentStartX = [self contentOffset].x;
    CGFloat currentEndX = currentStartX + [self frame].size.width;
    
    NSInteger pageIndexToDisplay = [self findPageIndexForOffset: currentStartX inRange: NSMakeRange(0, [[self pageRecords] count])];
    BOOL initialSelection = NO;
    if (pageIndexToDisplay == 0)
    {
        initialSelection = YES;
    }
    // RIT DEBUG
    //NSLog(@"pageIndexToDisplay: %d", pageIndexToDisplay);
    // RIT DEBUG
    NSMutableIndexSet* newVisiblePages = [[NSMutableIndexSet alloc] init];
    
    CGFloat xOrigin;
    CGFloat pageWidth;
    do
    {
        [newVisiblePages addIndex:pageIndexToDisplay];
        
        xOrigin = [self startPositionForPage:pageIndexToDisplay];
        pageWidth = [self widthForPage:pageIndexToDisplay];
        
        RITPage* page = [self cachedPageForIndex:pageIndexToDisplay];
        
        if (!page)
        {
            page = _dataSourceHas.pageAtIndex ? [_dataSource pagesNavigation:self pageAtIndex:pageIndexToDisplay] : nil;
            [self setCachedPage:page forIndex:pageIndexToDisplay];
            [page setFrame:CGRectMake(xOrigin, 0, pageWidth, CGRectGetHeight(self.bounds))];
            [self addSubview:page];
        }
        // RIT DEBUG
        //NSLog(@"page: %@", page);
        // RIT DEBUG
        pageIndexToDisplay++;
    }
    while (xOrigin + pageWidth < currentEndX && pageIndexToDisplay < [[self pageRecords] count]);
    
    if (initialSelection)
    {
        RITPage* page = [self cachedPageForIndex:0];
        if (CGRectIntersectsRect(page.frame, [self selectionZoneFrame])) {
            self.selectedPage = page;
        }
    }
    
    // RIT DEBUG
    //NSLog(@"newVisiblePages: %@", newVisiblePages);
    //NSLog(@"laying out %lu pages", (unsigned long)[newVisiblePages count]);
    // RIT DEBUG
    
    [self returnNonVisiblePagesToThePool:newVisiblePages];
}

- (NSInteger)findPageIndexForOffset:(CGFloat)xPosition inRange:(NSRange)range
{
    if ([[self pageRecords] count] == 0) return 0;
    
    RITPageRecord* pageRecord = [[RITPageRecord alloc] init];
    [pageRecord setStartPosition: xPosition];
    
    NSInteger returnValue = [[self pageRecords] indexOfObject: pageRecord
                                               inSortedRange: NSMakeRange(0, [[self pageRecords] count])
                                                     options: NSBinarySearchingInsertionIndex
                                             usingComparator: ^NSComparisonResult(RITPageRecord* pageRecord1, RITPageRecord* pageRecord2){
                                                 if ([pageRecord1 startPosition] < [pageRecord2 startPosition]) return NSOrderedAscending;
                                                 return NSOrderedDescending;
                                             }];
    if (returnValue == 0) return 0;
    return returnValue - 1;
}

- (void)generateWidthAndOffsetData
{
    CGFloat currentOffsetX = _contentMargin;
    NSMutableArray* newPageRecords = [NSMutableArray array];
    
    for (NSInteger pageIndex = 0; pageIndex < _pagesCount; pageIndex++)
    {
        RITPageRecord* pageRecord = [[RITPageRecord alloc] init];
        
        CGFloat pageWidth = _pageSize.width;
        
        [pageRecord setWidth:pageWidth];
        [pageRecord setStartPosition:currentOffsetX];
        [newPageRecords insertObject:pageRecord atIndex:pageIndex];
        currentOffsetX += pageWidth;
    }
    [self setPageRecords:newPageRecords];
    
    //[self setContentSize: CGSizeMake(currentOffsetX, CGRectGetHeight(self.bounds))];
}

#pragma mark -
#pragma mark Private methods

- (void)propertyInitialization
{
    self.backgroundColor = [UIColor clearColor];
    _pagesCount = 20;
    _animationOffsetRatio = 0.4f;
    _animationDuration = 0.3;
    [super setDelegate:self];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [self addGestureRecognizer:tapGesture];
    
    // RIT DEBUG
    /*
    _selectionView = [[UIView alloc] initWithFrame:self.selectionZoneFrame];
    _selectionView.backgroundColor = [UIColor yellowColor];
    [self addSubview:_selectionView];
    */
    // RIT DEBUG
    
    /*
    _horizontalPageOffset = 1.f;
    _verticalPageOffset = 0;
    CGSize initialThumbSize = CGSizeMake(CGRectGetHeight(self.bounds) - _horizontalPageOffset*2, CGRectGetHeight(self.bounds));
    [self updatePageBoundsWithPageSize:initialThumbSize andViewSize:self.bounds.size];
    */
}

- (void)scrollViewTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self];
    NSInteger pageIndexToDisplay = [self findPageIndexForOffset: pointInView.x inRange: NSMakeRange(0, [[self pageRecords] count])];
    [self scrollToPage:pageIndexToDisplay];
}

- (void)scrollToPage:(NSInteger)pageIndex
{
    CGFloat pageWidth = _pageSize.width;
    CGFloat pageScrollViewWidth = CGRectGetWidth(self.frame);
    CGFloat startPosition = [self startPositionForPage:pageIndex];
    CGPoint contentOffset = CGPointMake(startPosition - (pageScrollViewWidth - pageWidth) / 2, 0);
    [self setContentOffset:contentOffset animated:YES];
}

/*
- (void)updatePageBoundsWithPageSize:(CGSize)imageSize andViewSize:(CGSize)viewSize
{
    CGFloat pageRectWidth = imageSize.width + _horizontalPageOffset*2;
    CGFloat pageRectHeight = viewSize.height;
    _pageBounds = CGRectMake(0, 0, pageRectWidth, pageRectHeight);
    _verticalPageOffset = (viewSize.height - imageSize.height)/2;
    // RIT DEBUG
    NSLog(@"[%@ %@] -- _pageBounds: %@, _verticalPageOffset: %f", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_pageBounds), _verticalPageOffset);
    // RIT DEBUG
}
*/

- (void)setContentSize
{
    // RIT DEBUG
    //NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    CGFloat pageWidth = _pageSize.width;
    CGSize pagesScrollViewSize = self.bounds.size;
    _contentMargin = (pagesScrollViewSize.width - pageWidth) / 2;
    self.contentSize = CGSizeMake(pageWidth * _pagesCount + _contentMargin * 2, pagesScrollViewSize.height);
}

- (void)returnNonVisiblePagesToThePool:(NSMutableIndexSet*)currentVisiblePages
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- currentVisiblePages: %@", [self class], NSStringFromSelector(_cmd), currentVisiblePages);
    // RIT DEBUG
    [[self visiblePages] removeIndexes: currentVisiblePages];
    [[self visiblePages] enumerateIndexesUsingBlock:^(NSUInteger pageIndex, BOOL *stop)
     {
         RITPage* page = [self cachedPageForIndex:pageIndex];
         if (page)
         {
             [[self reusePool] addObject: page];
             [page removeFromSuperview];
             [self setCachedPage:nil forIndex:pageIndex];
         }
     }];
    // RIT DEBUG
    //NSLog(@"reusePool: %@", _reusePool);
    // RIT DEBUG
    [self setVisiblePages: currentVisiblePages];
}

#pragma mark -
#pragma mark Convenience methods for accessing page records

- (CGFloat)startPositionForPage:(NSInteger)pageIndex
{
    RITPageRecord *pageRecord = [[self pageRecords] objectAtIndex:pageIndex];
    return pageRecord.startPosition;
}

- (CGFloat)widthForPage:(NSInteger)page
{
    return [(RITPageRecord *)[[self pageRecords] objectAtIndex: page] width];
}

- (RITPage *)cachedPageForIndex:(NSInteger)pageIndex
{
    return [(RITPageRecord *)[[self pageRecords] objectAtIndex:pageIndex] cachedPage];
}

- (void)setCachedPage:(RITPage *)page forIndex:(NSInteger)pageIndex
{
    [(RITPageRecord *)[[self pageRecords] objectAtIndex: pageIndex] setCachedPage:page];
}

#pragma mark -
#pragma mark Accessors

- (void)setDataSource:(id<RITPagesNavigationDataSource>)newSource
{
    _dataSource = newSource;
    _dataSourceHas.pageAtIndex = [_dataSource respondsToSelector:@selector(pagesNavigation:pageAtIndex:)];
    _dataSourceHas.numberOfPagesForPagesNavigation = [_dataSource respondsToSelector:@selector(numberOfPagesForPagesNavigation:)];
    //[self reloadData];
}

- (void)setDelegate:(id<RITPagesNavigationDelegate>)newDelegate
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- newDelegate: %@", [self class], NSStringFromSelector(_cmd), newDelegate);
    // RIT DEBUG
    _pagesNavigationDelegate = newDelegate;
    
    // RITPagesNavigationDelegate protocol methods
    _delegateHas.tapOnPageWithIndex = [newDelegate respondsToSelector:@selector(pagesNavigation:tapOnPageWithIndex:)];
    _delegateHas.currentPageDidChange = [newDelegate respondsToSelector:@selector(pagesNavigation:currentPageDidChange:)];
    
    // UIScrollViewDelegate protocol methods
    _delegateHas.scrollViewDidScroll = [newDelegate respondsToSelector:@selector(scrollViewDidScroll:)];
    _delegateHas.scrollViewWillBeginDragging = [newDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
    _delegateHas.scrollViewDidEndDragging = [newDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
    _delegateHas.viewForZoomingInScrollView = [newDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)];
    _delegateHas.scrollViewWillBeginZooming = [newDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)];
    _delegateHas.scrollViewDidEndZooming = [newDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
    _delegateHas.scrollViewDidZoom = [newDelegate respondsToSelector:@selector(scrollViewDidZoom:)];
    _delegateHas.scrollViewDidEndScrollingAnimation = [newDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];
    _delegateHas.scrollViewWillBeginDecelerating = [newDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)];
    _delegateHas.scrollViewDidEndDecelerating = [newDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    _delegateHas.scrollViewWillEndDragging = [newDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)];
}

- (id<RITPagesNavigationDelegate>)delegate
{
    return _pagesNavigationDelegate;
}

/*
- (void)setHorizontalPageOffset:(CGFloat)newHorizontalPageOffset
{
    if (self.horizontalPageOffset == newHorizontalPageOffset) return;
    _horizontalPageOffset = newHorizontalPageOffset;
    [self updatePageBoundsWithPageSize:_pageSize andViewSize:self.bounds.size];
}
*/

- (void)setPageSize:(CGSize)newSize
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- newSize: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGSize(newSize));
    // RIT DEBUG
    if (CGSizeEqualToSize(_pageSize, newSize)) return;
    _pageSize = newSize;
    //[self updatePageBoundsWithPageSize:newSize andViewSize:self.bounds.size];
}

/*
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"[%@ %@] -- frame: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(self.frame));
}
*/

- (void)setBounds:(CGRect)newBounds
{
    if (!CGSizeEqualToSize(newBounds.size, self.bounds.size))
    {
        // RIT DEBUG
        NSLog(@"\n");
        NSLog(@"[%@ %@] -- bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(newBounds));
        // RIT DEBUG
        //[self updatePageBoundsWithPageSize:_pageSize andViewSize:newBounds.size];
    }
    [super setBounds:newBounds];
}

- (NSMutableSet*) reusePool
{
    if (!_reusePool)
    {
        _reusePool = [[NSMutableSet alloc] init];
    }
    
    return _reusePool;
}

- (NSMutableIndexSet*)visiblePages
{
    if (!_visiblePages)
    {
        _visiblePages = [[NSMutableIndexSet alloc] init];
    }
    
    return _visiblePages;
}

- (void) setSelectedPage:(RITPage *)newSelectedPage
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    if (newSelectedPage == _selectedPage) return;
    
    //CGFloat animationOffset = ceilf(self.selectedPage.offset.height)*0.5f;
    
    if (_selectedPage) {
        
        [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            //_selectedPage.backgroundColor = [UIColor blueColor];
            _selectedPage.center = CGPointMake(_selectedPage.center.x, _selectedPage.center.y + ceilf(_selectedPage.offset.height*_animationOffsetRatio));
            
        } completion:nil];
    }
    _selectedPage = newSelectedPage;
    [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        //_selectedPage.backgroundColor = [UIColor lightGrayColor];
        _selectedPage.center = CGPointMake(_selectedPage.center.x, _selectedPage.center.y - ceilf(_selectedPage.offset.height*_animationOffsetRatio));
        
    } completion:nil];
    if (_delegateHas.currentPageDidChange)
    {
        CGFloat startPosition = CGRectGetMinX(newSelectedPage.frame) + 1;
        NSInteger pageIndex = [self findPageIndexForOffset: startPosition inRange: NSMakeRange(0, [[self pageRecords] count])];
        [_pagesNavigationDelegate pagesNavigation:self currentPageDidChange:pageIndex];
    }
}

- (CGRect)selectionZoneFrame
{
    CGFloat pageWidth = _pageSize.width;
    CGFloat pageHeight = _pageSize.height;
    CGFloat pageScrollViewWidth = CGRectGetWidth(self.frame);
    _selectionZoneFrame = CGRectMake(self.contentOffset.x + (pageScrollViewWidth - pageWidth) / 2, 0, pageWidth, pageHeight);
    return _selectionZoneFrame;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    [self layoutPageViews];
    
    CGFloat currentStartX = [self contentOffset].x + _contentMargin + 1;
    NSInteger selectedPageIndex = [self findPageIndexForOffset: currentStartX inRange: NSMakeRange(0, [[self pageRecords] count])];
    // RIT DEBUG
    /*
    _selectionView.frame = self.selectionZoneFrame;
    [self bringSubviewToFront:_selectionView];
    */
    //NSLog(@"pageIndexToDisplay: %d", selectedPageIndex);
    // RIT DEBUG
    self.selectedPage = [self cachedPageForIndex:selectedPageIndex];
    
    if (_delegateHas.scrollViewDidScroll) {
        
        [_pagesNavigationDelegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- targetContentOffset: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGPoint(*targetContentOffset));
    // RIT DEBUG
    CGPoint point = *targetContentOffset;
    
    CGFloat targetStartX = point.x + _contentMargin + 1;
    NSInteger targetPageIndex = [self findPageIndexForOffset: targetStartX inRange: NSMakeRange(0, [[self pageRecords] count])];
    CGFloat startPosition = [self startPositionForPage:targetPageIndex];
    
    CGFloat pageWidth = _pageSize.width;
    CGFloat pageScrollViewWidth = CGRectGetWidth(self.frame);
    point = CGPointMake(startPosition - (pageScrollViewWidth - pageWidth) / 2, 0);
    *targetContentOffset = point;
    
    if (_delegateHas.scrollViewWillEndDragging) {
        
        [_pagesNavigationDelegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewWillBeginDragging) {
        
        [_pagesNavigationDelegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewDidEndDragging) {
        
        [_pagesNavigationDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewDidEndScrollingAnimation) {
        
        [_pagesNavigationDelegate scrollViewDidEndScrollingAnimation:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewWillBeginDecelerating) {
        
        [_pagesNavigationDelegate scrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewDidEndDecelerating) {
        
        [_pagesNavigationDelegate scrollViewDidEndDecelerating:self];
    }
}

@end
