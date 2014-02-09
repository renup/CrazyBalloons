//
//  PLTProximityInfo.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef NS_ENUM(NSUInteger, PLTProximity) {
	PLTProximityFar = 0,
    PLTProximityNear = 1,
	PLTProximityUnknown = 2
};


NSString *NSStringFromProximity(PLTProximity proximity);


@interface PLTProximityInfo : PLTInfo

@property(readonly)	PLTProximity	pcProximity;
@property(readonly)	PLTProximity	mobileProximity;

@end
