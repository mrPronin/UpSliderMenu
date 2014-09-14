//
//  RITPageRecord.h
//  UpSliderMenu
//
//  Created by Aleksandr Pronin on 14.09.14.
//  Copyright (c) 2014 Aleksandr Pronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RITPage;

@interface RITPageRecord : NSObject

@property (assign, nonatomic) CGFloat startPosition;
@property (assign, nonatomic) CGFloat width;
@property (strong, nonatomic) RITPage *cachedPage;

@end
