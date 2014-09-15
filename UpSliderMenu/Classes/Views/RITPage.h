//
//  RITPage.h
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RITPage : UIView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier offset:(CGSize)offset andImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame andText:(NSString*) text;

@property (strong, nonatomic) NSString *reuseIdentifier;
@property (assign, nonatomic) CGSize offset;

@end
