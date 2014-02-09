//
//  PLTDevice.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTInfo.h"
#import "PLTCalibration.h"
#import "PLTOrientationTrackingCalibration.h"
#import "PLTPedometerInfo.h"
#import "PLTWearingStateInfo.h"
#import "PLTProximityInfo.h"
#import "PLTOrientationTrackingInfo.h"
#import "PLTTapsInfo.h"
#import "PLTPedometerInfo.h"
#import "PLTFreeFallInfo.h"
#import "PLTMagnetometerCalibrationInfo.h"
#import "PLTGyroscopeCalibrationInfo.h"


#define PLT_API_VERSION		.1


extern NSString *const PLTDeviceNewDeviceAvailableNotification;
extern NSString *const PLTDeviceNewDeviceNotificationKey;


typedef NS_ENUM(NSUInteger, PLTService) {
	PLTServiceProximity =					0x00,
	PLTServiceWearingState =				0x01,
	PLTServiceOrientationTracking =			0x02,
	PLTServicePedometer =					0x03,
	PLTServiceFreeFall =					0x04,
	PLTServiceTaps =						0x05,
	PLTServiceMagnetometerCalStatus =		0x06,
	PLTServiceGyroscopeCalibrationStatus =	0x07
};

typedef NS_ENUM(NSUInteger, PLTSubscriptionMode) {
	PLTSubscriptionModeOnChange = 0,
	PLTSubscriptionModePeriodic = 1
};

typedef NS_ENUM(NSInteger, PLTDeviceErrorCode) {
	PLTDeviceErrorCodeUnknownError =				-1,
	PLTDeviceErrorCodeFailedToCreateDataSession =	1,
	PLTDeviceErrorCodeNoAccessoryAssociated =		2,
	PLTDeviceErrorCodeConnectionAlreadyOpen =		3,
	PLTDeviceErrorInvalidArgument =					4,
	PLTDeviceErrorInvalidService =					5,
	PLTDeviceErrorUnsupportedService =				6,
	PLTDeviceErrorInvalidMode =						7,
	PLTDeviceErrorUnsupportedMode =					8,
	PLTDeviceErrorIncompatibleVersions =			9
};


@class PLTConfiguration;
@class PLTCalibration;
@class PLTInfo;
@protocol PLTDeviceConnectionDelegate;
@protocol PLTDeviceInfoObserver;


@interface PLTDevice : NSObject

+ (NSArray *)availableDevices;
- (void)openConnection;
- (void)closeConnection;
- (void)setConfiguration:(PLTConfiguration *)aConfiguration forService:(PLTService)theService;
- (PLTConfiguration *)configurationForService:(PLTService)theService;
- (void)setCalibration:(PLTCalibration *)aCalibration forService:(PLTService)theService;
- (PLTCalibration *)calibrationForService:(PLTService)theService;
- (NSError *)subscribe:(id <PLTDeviceInfoObserver>)subscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode minPeriod:(NSUInteger)minPeriod;
//- (NSArray *)subscribe:(id <PLTDeviceInfoObserver>)subscriber toServices:(NSArray *)service withModes:(NSArray *)modes minPeriods:(NSArray *)minPeriods;
//- (NSArray *)subscribe:(id <PLTDeviceInfoObserver>)subscriber withMode:(PLTSubscriptionMode)mode minPeriod:(NSUInteger)minPeriod;
- (void)unsubscribe:(id <PLTDeviceInfoObserver>)subscriber fromService:(PLTService)service;
//- (void)unsubscribe:(id <PLTDeviceInfoObserver>)subscriber fromServices:(NSArray *)services;
- (void)unsubscribeFromAll:(id <PLTDeviceInfoObserver>)subscriber;
//- (NSArray *)subscriptions;
- (PLTInfo *)cachedInfoForService:(PLTService)aService;
- (void)queryInfo:(id <PLTDeviceInfoObserver>)subscriber forService:(PLTService)aService;

@property(assign)	id<PLTDeviceConnectionDelegate>	connectionDelegate;
@property(readonly)	BOOL							isConnectionOpen;
@property(readonly)	NSString						*model;
@property(readonly)	NSString						*name;
@property(readonly)	NSString						*serialNumber;
@property(readonly)	NSUInteger						fwMajorVersion;
@property(readonly)	NSUInteger						fwMinorVersion;
@property(readonly)	NSArray							*supportedServices;

@end


@protocol PLTDeviceConnectionDelegate <NSObject>

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice;
- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error;
- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice;

@end


@protocol PLTDeviceInfoObserver <NSObject>

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo;

@end
