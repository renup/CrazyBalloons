//
//  PLTOrientationTrackingCalibration.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTCalibration.h"
#import "PLTOrientationTrackingInfo.h"


@interface PLTOrientationTrackingCalibration : PLTCalibration

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles;
+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceQuaternion:(PLTQuaternion)referenceQuaternion;

@property(nonatomic, assign)	PLTEulerAngles	referenceEulerAngles;
@property(nonatomic, assign)	PLTQuaternion	referenceQuaternion;

@end
