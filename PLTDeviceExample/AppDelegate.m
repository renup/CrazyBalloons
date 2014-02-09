//
//  AppDelegate.m
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
//#import "SpaceBubbleViewController.h"
#import "SoundEffects.h"

@interface AppDelegate()
- (NSString *)myFilePath:(NSString *)fileName;

//@property(nonatomic, strong) ViewController *viewController;

@end


@implementation AppDelegate

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
//	self.window.rootViewController = self.viewController;
//    [self.window makeKeyAndVisible];
//	
//    return YES;
//}

@synthesize window;
@synthesize viewController;

+ (void)initialize {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    InitializeSoundEffects();
    
    // Prevent the screen from sleeping!  Important!!  (AngryBirds doesn't do this btw...annoying)
    [application setIdleTimerDisabled:YES];
    
    // Hide Status Bar and enter Full Screen
    application.statusBarHidden = YES;
//    [application setStatusBarHidden:YES animated:NO];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [self myFilePath:@"HighScore.archive"];
    
    if([fileManager fileExistsAtPath:filePath]) {
        NSNumber *aNumber = [NSKeyedUnarchiver unarchiveObjectWithFile:[self myFilePath:@"HighScore.archive"]];
        viewController.highScore = [aNumber unsignedIntegerValue];
    }
    else {
        viewController.highScore = 0;
    }
    
    filePath = [self myFilePath:@"BackgroundMusic.archive"];
    
    if([fileManager fileExistsAtPath:filePath]) {
        NSNumber *aNumber = [NSKeyedUnarchiver unarchiveObjectWithFile:[self myFilePath:@"BackgroundMusic.archive"]];
        viewController.backgroundMusic = [aNumber boolValue];
    }
    else {
        viewController.backgroundMusic = YES;
    }
    
    filePath = [self myFilePath:@"SoundEffects.archive"];
    
    if([fileManager fileExistsAtPath:filePath]) {
        NSNumber *aNumber = [NSKeyedUnarchiver unarchiveObjectWithFile:[self myFilePath:@"SoundEffects.archive"]];
        viewController.soundEffects = [aNumber boolValue];
    }
    else {
        viewController.soundEffects = YES;
    }
    //	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //	self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}

- (void)saveData {
    NSUInteger currentScore = viewController.highScore;
    NSNumber *countNumber = [NSNumber numberWithUnsignedInt:currentScore];
    
    [NSKeyedArchiver archiveRootObject:countNumber toFile:[self myFilePath:@"HighScore.archive"]];
    
    countNumber = [NSNumber numberWithBool:viewController.backgroundMusic];
    [NSKeyedArchiver archiveRootObject:countNumber toFile:[self myFilePath:@"BackgroundMusic.archive"]];
    
    countNumber = [NSNumber numberWithBool:viewController.soundEffects];
    [NSKeyedArchiver archiveRootObject:countNumber toFile:[self myFilePath:@"SoundEffects.archive"]];
}

// ***** Still need this to support iPhone OS 3 but is never actually called on iOS 4 **** //
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveData];
}

// ***** Had to add this to support multitasking in iOS 4 **** //
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveData];
    
}

- (NSString *)myFilePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}





@end
