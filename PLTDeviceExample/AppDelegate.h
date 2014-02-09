//
//  AppDelegate.h
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIWindow *window;
//    ViewController *viewController;
    NSUInteger score;
}

- (void)saveData;
@property (strong, nonatomic)IBOutlet UIWindow *window;
@property (weak, nonatomic) IBOutlet ViewController *viewController;

//@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet ViewController *viewController;

@end
