//
//  RITPagesNavigationViewController.h
//  UpSliderMenu
//
//  Created by Pronin Alexander on 11.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITPagesNavigation.h"

@interface RITPagesNavigationViewController : UIViewController <RITPagesNavigationDelegate, RITPagesNavigationDataSource>

@property (weak, nonatomic) IBOutlet RITPagesNavigation *scrollView;

@end
