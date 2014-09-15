//
//  RITPageRecord.m
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 14.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import "RITPageRecord.h"

@implementation RITPageRecord

- (NSString*) description
{
    return [NSString stringWithFormat:@"startPosition: %f width: %f cachedPage: %@", _startPosition, _width, _cachedPage];
}

@end
