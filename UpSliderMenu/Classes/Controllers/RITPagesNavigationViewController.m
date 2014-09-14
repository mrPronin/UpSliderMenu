//
//  RITPagesNavigationViewController.m
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPagesNavigationViewController.h"

@interface RITPagesNavigationViewController ()

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
    
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.pageSize = CGSizeMake(12.f, 15.f);
    [_scrollView reloadData];
    //_scrollView.horizontalPageOffset = 1.f;
    //_scrollView.pageImage = [UIImage imageNamed:@"pages"];
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

#pragma mark -
#pragma mark RITPagesNavigationDataSource

- (RITPage *)pagesNavigation:(RITPagesNavigation *)pagesNavigation pageAtIndex:(NSUInteger)pageIndex
{
    NSString* reuseIdentifier = [NSString stringWithFormat:@"Page%02d", pageIndex];
    RITPage* page = [_scrollView  dequeueReusablePageWithIdentifier:reuseIdentifier];
    if (!page)
    {
        /*
        CGRect pageFrame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
        page = [RITPage alloc] initWithFrame:<#(CGRect)#> text:<#(NSString *)#> andReuseIdentifier:<#(NSString *)#>;
        page.verticalOffset = (CGRectGetHeight(_scrollView.frame) - _scrollView.pageSize.height)/2;
        */
    }
    
    return nil;
}

- (NSUInteger)numberOfPagesForPagesNavigation:(RITPagesNavigation *)pagesNavigation
{
    return 53;
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
