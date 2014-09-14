//
//  RITPage.h
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RITPage : UIView

- (id)initWithFrame:(CGRect)frame text:(NSString *)text andReuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithFrame:(CGRect)frame andText:(NSString*) text;

@property (strong, nonatomic) NSString *reuseIdentifier;
@property (assign, nonatomic) CGFloat verticalOffset;
@property (assign, nonatomic) CGFloat horizontalOffset;

@end
