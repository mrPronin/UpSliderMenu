//
//  RITMenuScrollViewController.h
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RITMenuScrollViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)actionScrollToPageButton:(UIButton *)sender;
@end
