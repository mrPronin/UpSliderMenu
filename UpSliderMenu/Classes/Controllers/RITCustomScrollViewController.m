//
//  RITCustomScrollViewController.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 03.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITCustomScrollViewController.h"

@interface RITCustomScrollViewController ()

@property (nonatomic, strong) UIView *containerView;
- (void)centerScrollViewContents;

@end

@implementation RITCustomScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the container view to hold your custom view hierarchy
    CGSize containerSize = CGSizeMake(640.0f, 640.0f);
    self.containerView = [[UIView alloc] initWithFrame:(CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=containerSize}];
    [self.scrollView addSubview:self.containerView];
    
    // Set up your custom view hierarchy
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 640.0f, 80.0f)];
    redView.backgroundColor = [UIColor redColor];
    [self.containerView addSubview:redView];
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 560.0f, 640.0f, 80.0f)];
    blueView.backgroundColor = [UIColor blueColor];
    [self.containerView addSubview:blueView];
    
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(160.0f, 160.0f, 320.0f, 320.0f)];
    greenView.backgroundColor = [UIColor greenColor];
    [self.containerView addSubview:greenView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slow.png"]];
    imageView.center = CGPointMake(320.0f, 320.0f);
    [self.containerView addSubview:imageView];
    
    // Tell the scroll view the size of the contents
    self.scrollView.contentSize = containerSize;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = 1.0f;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.containerView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
