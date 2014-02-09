//
//  PLTTapsInfo.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef NS_ENUM(NSUInteger, PLTTapDirection) {
    PLTTapDirectionXUp = 1,
    PLTTapDirectionXDown,
    PLTTapDirectionYUp,
    PLTTapDirectionYDown,
    PLTTapDirectionZUp,
    PLTTapDirectionZDown
};


NSString *NSStringFromTapDirection(PLTTapDirection direction);


@interface PLTTapsInfo : PLTInfo

@property(readonly)	NSUInteger		taps;
@property(readonly)	PLTTapDirection	direction;

@end
