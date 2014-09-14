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

@end

@implementation RITPagesNavigation {
    //CGRect _pageBounds;
    //CGFloat _verticalPageOffset;
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
    NSLog(@"[%@ %@] _dataSource: %@", [self class], NSStringFromSelector(_cmd), _dataSource);
    // RIT DEBUG
    
    if (!_dataSource) return;
    _pagesCount = _dataSourceHas.numberOfPagesForPagesNavigation ?[_dataSource numberOfPagesForPagesNavigation:self] : 0;
    
    [self returnNonVisiblePagesToThePool:nil];
    [self generateWidthAndOffsetData];
    [self setContentSize];
    [self layoutPageViews];
    
    
    //[self updateVisibleBars];
    //[self setNeedsLayout];
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

- (void)layoutPageViews
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    CGFloat currentStartX = [self contentOffset].x;
    CGFloat currentEndX = currentStartX + [self frame].size.width;
    
    NSInteger pageIndexToDisplay = [self findPageIndexForOffset: currentStartX inRange: NSMakeRange(0, [[self pageRecords] count])];
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
        
        pageIndexToDisplay++;
    }
    while (xOrigin + pageWidth < currentEndX && pageIndexToDisplay < [[self pageRecords] count]);
    
    NSLog(@"laying out %lu pages", (unsigned long)[newVisiblePages count]);
    
    [self returnNonVisiblePagesToThePool:newVisiblePages];
}

- (void)generateWidthAndOffsetData
{
    CGFloat currentOffsetX = 0.0;
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
    
    /*
    _horizontalPageOffset = 1.f;
    _verticalPageOffset = 0;
    CGSize initialThumbSize = CGSizeMake(CGRectGetHeight(self.bounds) - _horizontalPageOffset*2, CGRectGetHeight(self.bounds));
    [self updatePageBoundsWithPageSize:initialThumbSize andViewSize:self.bounds.size];
    */
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

- (void)updateVisibleBars
{
    // RIT DEBUG
    //NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
}

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
    [[self visiblePages] removeIndexes: currentVisiblePages];
    [[self visiblePages] enumerateIndexesUsingBlock:^(NSUInteger pageIndex, BOOL *stop)
     {
         RITPage* page = [self cachedPageForIndex:pageIndex];
         if (page)
         {
             [[self reusePool] addObject: page];
             [page removeFromSuperview];
             [self setCachedPage:page forIndex:pageIndex];
         }
     }];
    [self setVisiblePages: currentVisiblePages];
}

#pragma mark -
#pragma mark Convenience methods for accessing page records

- (CGFloat)startPositionForPage:(NSInteger)page
{
    return [(RITPageRecord *)[[self pageRecords] objectAtIndex: page] startPosition];
}

- (CGFloat)widthForPage:(NSInteger)page
{
    return [(RITPageRecord *)[[self pageRecords] objectAtIndex: page] width];
}

- (RITPage *)cachedPageForIndex:(NSInteger)pageIndex
{
    return [(RITPageRecord *)[[self pageRecords] objectAtIndex:pageIndex] cachedPage];
}

- (void) setCachedPage:(RITPage *)page forIndex:(NSInteger)pageIndex
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
    _pagesNavigationDelegate = newDelegate;
    
    // RITPagesNavigationDelegate protocol methods
    _delegateHas.tapOnPageWithIndex = [newDelegate respondsToSelector:@selector(pagesNavigation:tapOnPageWithIndex:)];
    
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
    NSLog(@"[%@ %@] -- newPageThumbViewSize: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGSize(newSize));
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

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] --", [self class], NSStringFromSelector(_cmd));
    // RIT DEBUG
    
    [self layoutPageViews];
    
    if (_delegateHas.scrollViewDidScroll) {
        
        [_pagesNavigationDelegate scrollViewDidScroll:self];
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- targetContentOffset: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGPoint(*targetContentOffset));
    // RIT DEBUG
    
    if (_delegateHas.scrollViewWillEndDragging) {
        
        [_pagesNavigationDelegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

@end
