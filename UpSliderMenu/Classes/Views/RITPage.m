//
//  RITPage.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPage.h"

@interface RITPage ()

@property (strong, nonatomic) UILabel *label;

@end

@implementation RITPage

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
*/


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier offset:(CGSize)offset andImage:(UIImage *)image
{
    self = [super initWithFrame: CGRectZero];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [self randomColor];
        
        CGRect imageFrame = CGRectMake(ceilf(offset.width), ceilf(offset.height), image.size.width, image.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = imageFrame;
        [self addSubview:imageView];
        
        _reuseIdentifier = reuseIdentifier;
        _offset = offset;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andText:(NSString*) text
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.backgroundColor = [UIColor blueColor];
        self.backgroundColor = [self randomColor];
        
        _label = [[UILabel alloc] init];
        _label.frame = self.bounds;
        _label.text = text;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_label];
        
    }
    return self;
}

- (UIColor*) randomColor {
    
    CGFloat r = (float)(arc4random() % 256) / 255.f;
    CGFloat g = (float)(arc4random() % 256) / 255.f;
    CGFloat b = (float)(arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

- (void) dealloc
{
    //NSLog(@"View deallocated: %@", _label.text);
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"reuseIdentifier: %@ label: %@ frame: %@", _reuseIdentifier, _label.text, NSStringFromCGRect(self.frame)];
}

@end
