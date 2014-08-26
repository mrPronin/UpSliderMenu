//
//  RITPageThumbView.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 04.07.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPageThumbView.h"

@interface RITPageThumbView ()

@property (strong, nonatomic) UILabel *label;

@end

@implementation RITPageThumbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andText:(NSString*) text
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blueColor];
        
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

- (void) dealloc
{
    //NSLog(@"View deallocated: %@", _label.text);
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ label=%@", [super description], _label.text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
