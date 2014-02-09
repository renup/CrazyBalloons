//
//  ViewController.h
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <iAd/ADBannerView.h>

#import "GameOverViewController.h"
#import "SpriteHelpers.h"
#import "SplashViewController.h"

@interface ViewController : UIViewController<UIAccelerometerDelegate, AVAudioPlayerDelegate, ADBannerViewDelegate>{
    Sprite *shipView;
    Sprite *enemyView;
    Sprite *bonusView;
    
    UIImageView *splashScreen;
    
    SplashViewController *splashView;
    
    BOOL soundEffects;
    BOOL backgroundMusic;
    BOOL bonusTime;
    BOOL gamePaused;
    NSMutableArray *enemyArray;
    NSMutableArray *bonusArray;
    UILabel *scoreLabel;
    UILabel *livesLabel;
    NSInteger pointCount;
    NSUInteger enemyRandFeed;
    NSUInteger bonusRandFeed;
    NSUInteger scorePlaceholder;
    NSInteger lives;
    CGFloat halfEnemyWidth;
    CGFloat halfShipWidth;
    CGFloat halfBonusWidth;
    NSTimer *bonusTimer;
    NSTimer *isBonusTimer;
    NSTimer *updateTimer;
    NSUInteger highScore;
    GameOverViewController *gameOverView;
    
    AVAudioPlayer *player;
    
    ADBannerView *_adBannerView;
    BOOL bannerIsVisible;
}

@property (nonatomic, retain) NSTimer *bonusTimer;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) NSTimer *isBonusTimer;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UILabel *livesLabel;
@property (nonatomic, assign) NSUInteger highScore;
@property (nonatomic, assign) BOOL gamePaused;
@property (nonatomic, assign) BOOL soundEffects;
@property (nonatomic, assign) BOOL backgroundMusic;
@property (nonatomic, retain) AVAudioPlayer *player;

@property (nonatomic, retain) ADBannerView *adBannerView;
@property (nonatomic, assign) BOOL bannerIsVisible;

- (void)displayHideSplashScreen;
- (void)updateScore:(NSUInteger)score;
- (void)createAdBannerView;

@end
