//
//  PLTOrientationTrackingInfo.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef struct {
	double x;
	double y;
	double z;
} PLTEulerAngles;

typedef struct {
	double w;
	double x;
	double y;
	double z;
} PLTQuaternion;


PLTEulerAngles EulerAnglesFromQuaternion(PLTQuaternion quaternion);
PLTQuaternion QuaternionFromEulerAngles(PLTEulerAngles eulerAngles);
NSString *NSStringFromEulerAngles(PLTEulerAngles angles);
NSString *NSStringFromQuaternion(PLTQuaternion quaternion);


@interface PLTOrientationTrackingInfo : PLTInfo

@property(readonly)	PLTEulerAngles	eulerAngles;
@property(readonly)	PLTQuaternion	quaternion;
@property(readonly)	PLTEulerAngles	rawEulerAngles;
@property(readonly)	PLTQuaternion	rawQuaternion;
@property(readonly)	PLTEulerAngles	referenceEulerAngles;
@property(readonly)	PLTQuaternion	referenceQuaternion;

@end
