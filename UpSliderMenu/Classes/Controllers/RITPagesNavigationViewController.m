//
//  RITPagesNavigationViewController.m
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPagesNavigationViewController.h"

const NSUInteger pageNumber = 53;

@interface RITPagesNavigationViewController ()

@property (strong, nonatomic) UIImage *pageImage;
@property (assign, nonatomic) CGFloat horizontalOffset;

@end

@implementation RITPagesNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _horizontalOffset = 2.f;
    _pageImage = [UIImage imageNamed:@"pages"];
    CGSize imageSize = _pageImage.size;
    
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    // RIT DEBUG
    _scrollView.pageSize = CGSizeMake(imageSize.width + _horizontalOffset*2, CGRectGetHeight(_scrollView.frame));
    //_scrollView.pageSize = CGSizeMake(50, CGRectGetHeight(_scrollView.frame));
    // RIT DEBUG
    [_scrollView reloadData];
    //NSLog(@"[%@ %@] -- ", [self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark RITPagesNavigationDelegate

- (void)pagesNavigation:(RITPagesNavigation *)pagesNavigation tapOnPageWithIndex:(NSUInteger)pageIndex
{
    
}

- (void)pagesNavigation:(RITPagesNavigation *)pagesNavigation currentPageDidChange:(NSUInteger)pageIndex
{
    //NSLog(@"[%@ %@] -- page: %d", [self class], NSStringFromSelector(_cmd), pageIndex);
    _pageNumberLabel.text = [NSString stringWithFormat:@"%d/%d", pageIndex + 1, pageNumber];
}

#pragma mark -
#pragma mark RITPagesNavigationDataSource

- (RITPage *)pagesNavigation:(RITPagesNavigation *)pagesNavigation pageAtIndex:(NSUInteger)pageIndex
{
    NSString* reuseIdentifier = [NSString stringWithFormat:@"Page%02d", pageIndex];
    RITPage* page = [_scrollView  dequeueReusablePageWithIdentifier:reuseIdentifier];
    if (!page)
    {
        CGSize imageSize = _pageImage.size;
        CGFloat verticalOffset = (CGRectGetHeight(_scrollView.frame) - imageSize.height)*0.7f;
        CGSize offset = CGSizeMake(_horizontalOffset, verticalOffset);
        //NSString *text = [NSString stringWithFormat:@"%02d", pageIndex];
        page = [[RITPage alloc] initWithReuseIdentifier:reuseIdentifier offset:offset andImage:_pageImage];;
    }
    
    //NSLog(@"[%@ %@] -- page: %@", [self class], NSStringFromSelector(_cmd), page);
    return page;
}

- (NSUInteger)numberOfPagesForPagesNavigation:(RITPagesNavigation *)pagesNavigation
{
    return pageNumber;
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"[%@ %@] -- ", [self class], NSStringFromSelector(_cmd));
}
 */

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"[%@ %@] -- ", [self class], NSStringFromSelector(_cmd));
    [_scrollView reloadData];
    /*
    if (fromInterfaceOrientation == UIDeviceOrientationPortrait) {
        CGRect scrollViewFrame = _scrollView.frame;
        scrollViewFrame.size.height = 100;
        _scrollView.frame = scrollViewFrame;
        [_scrollView setNeedsDisplay];
    }
    */
    
}

@end
