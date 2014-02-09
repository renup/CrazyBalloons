//
//  PLTInfo.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, PLTInfoRequestType) {
	PLTInfoRequestTypeSubscription = 0,
	PLTInfoRequestTypeQuery = 1
};


@class PLTDevice;

@interface PLTInfo : NSObject

//@property(readonly)	PLTDevice			*device;
@property(readonly)	PLTInfoRequestType	requestType;
@property(readonly) NSDate				*timestamp;

@end
