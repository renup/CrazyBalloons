//
//  ViewController.m
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"
#import "SoundEffects.h"

#define kAccelerometerFrequency 200
#define kAccelerationSpeed 6
#define kEnemyCount 4
#define kBonusSpeed 0.009
#define kBonusInterval 1
#define kUpdateSpeed 0.009
#define kNewLifePoints 10000


#define DEVICE_IPAD         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface ViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)subscribeToInfo;
- (void)startFreeFallResetTimer;
- (void)stopFreeFallResetTimer;
- (void)freeFallResetTimer:(NSTimer *)theTimer;
- (void)startTapsResetTimer;
- (void)stopTapsResetTimer;
- (void)tapsResetTimer:(NSTimer *)theTimer;
- (IBAction)calibrateOrientationButton:(id)sender;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, strong)	NSTimer					*freeFallResetTimer;
@property(nonatomic, strong)	NSTimer					*tapsResetTimer;
//@property(nonatomic, strong)	IBOutlet UIProgressView	*headingProgressView;
//@property(nonatomic, strong)	IBOutlet UIProgressView	*pitchProgressView;
//@property(nonatomic, strong)	IBOutlet UIProgressView	*rollProgressView;
//@property(nonatomic, strong)	IBOutlet UILabel		*headingLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*pitchLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*rollLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*wearingStateLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*mobileProximityLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*pcProximityLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*tapsLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*pedometerLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*freeFallLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*magnetometerCalLabel;
//@property(nonatomic, strong)	IBOutlet UILabel		*gyroscopeCalLabel;

@end


@implementation ViewController
@synthesize bonusTimer, isBonusTimer, updateTimer, scoreLabel, livesLabel, highScore, player, gamePaused, soundEffects, backgroundMusic;
@synthesize adBannerView = _adBannerView;
@synthesize bannerIsVisible;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup background music
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"GameLoop" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    //	[fileURL release];
    self.player = newPlayer;
    //	[newPlayer release];
    [player prepareToPlay];
    [player setNumberOfLoops:-1];
    [player setDelegate: self];
    
    // Make sure the user hasn't turned off background music.  If they have, then don't play the music.
    if(backgroundMusic) {
        [self.player play];
    }
    
    // Setup Background
    //NSString *backgroundPath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"];
    //UIImage *background = [[UIImage alloc] initWithContentsOfFile: backgroundPath];
    UIImage *background = [UIImage imageNamed: @"background.png"];
    
    UIImageView *backgroundViewTemp = [[UIImageView alloc] initWithImage:background];
    [self.view addSubview:backgroundViewTemp];
    
    //	[backgroundViewTemp release];
    //[background release];
    
    // Setup Enemies
    enemyArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < kEnemyCount; i++) {
        [enemyArray addObject:[SpriteHelpers setupAnimatedSprite:self.view numFrames:3 withFilePrefix:@"bubbleiconnew" withDuration:((CGFloat)(arc4random()%2)/3 + 0.5) ofType:@"png" withValue:0]];
    }
    
    enemyView = [enemyArray objectAtIndex:0];
    
    // Setup Bonus
    bonusArray = [[NSMutableArray alloc] init];
    
    [bonusArray addObject:[SpriteHelpers setupAnimatedSprite:self.view numFrames:3 withFilePrefix:@"bonus" withDuration:0.4 ofType:@"png" withValue:250]];
    [bonusArray addObject:[SpriteHelpers setupAnimatedSprite:self.view numFrames:3 withFilePrefix:@"2bonus" withDuration:0.4 ofType:@"png" withValue:350]];
    [bonusArray addObject:[SpriteHelpers setupAnimatedSprite:self.view numFrames:3 withFilePrefix:@"3bonus" withDuration:0.4 ofType:@"png" withValue:500]];
    
    for(Sprite *bonusEnum in bonusArray) {
        bonusEnum.fValue = (arc4random()%3) + 1;
    }
    
    bonusView = [bonusArray objectAtIndex:arc4random()%3];
    bonusTime = NO;
    
    // Setup Ship
    NSString *shipPath = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"png"];
    UIImage *ship = [[UIImage alloc] initWithContentsOfFile: shipPath];
    Sprite *shipViewTemp = [[UIImageView alloc] initWithImage:ship];
    
    shipView = shipViewTemp;
    
    shipViewTemp.center = CGPointMake(160, 480 - (shipView.image.size.height / 2));
    [self.view addSubview:shipViewTemp];
    
    //	[shipViewTemp release];
    //	[ship release];
    
    // Setup Scoreboard
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 320, 20)];
    pointCount = 0;
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", pointCount];
    [self.view addSubview:scoreLabel];
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.font = [UIFont boldSystemFontOfSize:22];
    
    // Setup Life Counter
    livesLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 1, 100, 20)];
    lives = 5;
    livesLabel.text = [NSString stringWithFormat:@"Lives: %d", lives];
    [self.view addSubview:livesLabel];
    livesLabel.textColor = [UIColor whiteColor];
    livesLabel.backgroundColor = [UIColor clearColor];
    livesLabel.font = [UIFont boldSystemFontOfSize:22];
    
    // Setup Accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    // Setup Timers
    self.bonusTimer = [NSTimer scheduledTimerWithTimeInterval:kBonusSpeed target:self selector:@selector(bonusTimerCallback:) userInfo:nil repeats:YES];
    self.isBonusTimer = [NSTimer scheduledTimerWithTimeInterval:kBonusInterval target:self selector:@selector(isBonusTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateSpeed target:self selector:@selector(updateTimerCallback:) userInfo:nil repeats:YES];
    
    // Some math we can do ahead of time to shave precious iPhone CPU cycles later
    halfEnemyWidth = enemyView.image.size.width / 2;
    halfShipWidth = shipView.image.size.width / 2;
    halfBonusWidth = bonusView.image.size.width / 2;
    enemyRandFeed = (NSUInteger)(320 - enemyView.image.size.width);
    bonusRandFeed = (NSUInteger)(320 - bonusView.image.size.width);
    
    // Display Ads
    [self createAdBannerView];
    //
    //	if (_adBannerView != nil) {
    //        [_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
    //		CGRect adBannerViewFrame = [_adBannerView frame];
    //		adBannerViewFrame.origin.y = 0;
    //		[_adBannerView setFrame:adBannerViewFrame];
    //		[scoreLabel setCenter:CGPointMake(scoreLabel.center.x, scoreLabel.center.y + 50)];
    //		[livesLabel setCenter:CGPointMake(livesLabel.center.x, livesLabel.center.y + 50)];
    //		bannerIsVisible = YES;
    //    } else {
    bannerIsVisible = NO;
    //	}
    
    
    // DisplaySplash Screen
    gamePaused = NO;
    [self displayHideSplashScreen];
    
    scorePlaceholder = 0;
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) completed {
    if (completed == YES) {
        //[self.player play];
    }
}

// displayHideSplashScreen displays and hides the Splash Screen that contains our settings button, pauses game, display instructions etc...
- (void)displayHideSplashScreen {
    if(gamePaused == YES) {
        gamePaused = NO;
    } else {
        splashView = [[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
        [self.view addSubview:splashView.view];
        [splashView setMyCreator:self];
        
        gamePaused = YES;
    }
    
    if(soundEffects) {
        PlaySoundEffect(Sound_Mechanical);
    }
}

// This timer is called every kBonusInterval seconds and is randomized so a bonus can show up anywhere from kBonusInterval to 5 * kBonusInterval
- (void)isBonusTimerCallback:(id)sender {
    if(gamePaused == NO) {
        if(arc4random()%5 == 1) {
            bonusTime = YES;
        }
        
    }
}

// This timer checks if a bonus is activated, and if it is it moves it down and checks for contact with the ship then turns off the bonus
- (void)bonusTimerCallback:(id)sender {
    if(gamePaused == NO) {
        if(bonusTime == YES) {
            CGPoint bonusCenter = bonusView.center;
            
            bonusCenter.y += bonusView.fValue;
            
            CGRect rect = CGRectMake(shipView.center.x - halfShipWidth, shipView.center.y - halfShipWidth, shipView.image.size.width, shipView.image.size.height);
            
            // Check for collision with bonus item
            if(CGRectContainsPoint(rect, bonusCenter)) {
                // Get integer value of our Sprite, which in our bonus's case is the point value and update the score
                [self updateScore:bonusView.iValue];
                
                if(soundEffects) {
                    PlaySoundEffect(Sound_Hit);
                }
                
                // Move bonus offscreen so it can be collected and reset below
                bonusCenter.y = 480 + bonusView.image.size.height;
            }
            
            // Reset bonus of it moves offscreen
            if(bonusCenter.y > 480) {
                bonusCenter.y = -bonusView.image.size.height; // Move current bonus up top offscreen
                bonusCenter.x = (arc4random()%bonusRandFeed) + halfBonusWidth; // Randomize x-pos of bonus
                
                [bonusView setCenter:bonusCenter]; // Update position
                
                bonusView = [bonusArray objectAtIndex:arc4random()%3]; // Randomize Bonus Type
                bonusView.fValue = (arc4random()%3) + 1; // Randomize the speed it falls
                bonusTime = NO; // Turn off bonus (our isBonusTimer will turn this on at random)
            }
            
            [bonusView setCenter:bonusCenter];
        }
    }
}

// updateScore sets the score to given value and updates labels accordingly including adding new lives
// every time the score increases by kNewLifePoints as #defined above.
- (void)updateScore:(NSUInteger)score {
    scorePlaceholder += score;
    pointCount += score;
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", pointCount];
    
    if(scorePlaceholder >= kNewLifePoints) {
        lives++;
        livesLabel.text = [NSString stringWithFormat:@"Lives: %d", lives];
        scorePlaceholder -= kNewLifePoints;
    }
}

- (void)updateTimerCallback:(id)sender {
    if(gamePaused == NO) {
        CGPoint enemyCenter;
        CGFloat inc = 0.6;
        
        // Create a CGRect that defines our ship
        CGRect shipRect = CGRectMake(shipView.center.x - halfShipWidth, shipView.center.y - halfShipWidth, shipView.image.size.width, shipView.image.size.height);
        
        for(Sprite *enemyEnum in enemyArray) {
            enemyCenter = enemyEnum.center;
            inc = inc + 0.6; // As we cycle through our bad guys we increase the speed so they aren't all dropping at the same rate
            enemyCenter.y += inc; // Increase the Y position of our bad guy so he drops down.
            
            // If enemy hits our ship, increase the hit counter place him offscreen below.  Code below will recycle him up top if needed.
            if(CGRectContainsPoint(shipRect, enemyCenter)) {
                if(soundEffects) {
                    PlaySoundEffect(Sound_AxeThrow);
                }
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // Vibrate the phone AGH WE'VE BEEN HIT!
                lives--;
                livesLabel.text = [NSString stringWithFormat:@"Lives: %d", lives];
                enemyCenter.y = 480 + enemyEnum.image.size.height;
            }
            
            // If enemy goes offscreen, recycle him and place him up top at a random X coordinate
            if(enemyCenter.y > 480) {
                [self updateScore:5];
                enemyCenter.y = -enemyEnum.image.size.height;
                enemyCenter.x = (arc4random()%enemyRandFeed) + halfEnemyWidth;
            }
            
            [enemyEnum setCenter:enemyCenter];
        }
        
        // Game Over
        if(lives <= 0) {
            // Display splash screen, stop game from updating
            [self displayHideSplashScreen];
            
            // Create gameover screen
            if(gameOverView == nil)
            {
                gameOverView = [[GameOverViewController alloc] initWithNibName:@"GameOverViewController" bundle:nil];
            }
            
            // Check if we have a new high score.
            if(highScore < pointCount) {
                highScore = pointCount;
            }
            
            if(soundEffects) {
                PlaySoundEffect(Sound_Alien);
            }
            
            // Pass the high score to our gameover viewcontroller so it can display it
            [gameOverView setHighScore:self.highScore];
            
            // Display gameover screen
            [self.view addSubview:gameOverView.view];
            
            lives = 5;
            livesLabel.text = [NSString stringWithFormat:@"Lives: %d", lives];
            scorePlaceholder = 0;
            pointCount = 0;
            [self updateScore:0];
            
            // Cycle through our enemies and reset all the bad guys to the top
            for(Sprite *enemyEnum in enemyArray) {
                enemyCenter = enemyEnum.center;
                enemyCenter.y = -enemyEnum.image.size.height; // Move enemy up top offscreen
                enemyCenter.x = (arc4random()%enemyRandFeed) + halfEnemyWidth; // Randomize x-pos of enemy
                
                [enemyEnum setCenter:enemyCenter]; // Set enemy's position to our CGPoint value
                
                // Alternatively we can do the following that compresses the above 4 lines of code
                // but it makes for difficult reading the code although it may be faster
                // [enemyEnum setCenter:CGPointMake((arc4random()%enemyRandFeed) + halfEnemyWidth, -enemyEnum.image.size.height)];
            }
            
            // Reset bonus
            CGPoint bonusCenter = bonusView.center;
            
            bonusCenter.y = -bonusView.image.size.height; // Move current bonus up top offscreen
            bonusCenter.x = (arc4random()%bonusRandFeed) + halfBonusWidth; // Randomize x-pos of bonus
            bonusTime = NO;
            
            [bonusView setCenter:bonusCenter];
            bonusView = [bonusArray objectAtIndex:arc4random()%3]; // Randomize bonus type
        }
    }
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[classAdBannerView alloc] initWithFrame:CGRectZero];
        //        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil]];
        //		[_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
        //        [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, -50)];
        //        [_adBannerView setDelegate:self];
        //
        //        [self.view addSubview:_adBannerView];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if(!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        bannerIsVisible = YES;
        
        [scoreLabel setCenter:CGPointMake(scoreLabel.center.x, scoreLabel.center.y + 50)];
        [livesLabel setCenter:CGPointMake(livesLabel.center.x, livesLabel.center.y + 50)];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if(bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        bannerIsVisible = NO;
        
        [scoreLabel setCenter:CGPointMake(scoreLabel.center.x, scoreLabel.center.y - 50)];
        [livesLabel setCenter:CGPointMake(livesLabel.center.x, livesLabel.center.y - 50)];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    if (!willLeave){
        if(backgroundMusic) {
            [player stop];
        }
        
        [self displayHideSplashScreen];
    }
    
    return YES;	
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    if(backgroundMusic) {
        [player play];
    }
    
    [splashView dismiss];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    
    //ANIL temporarily skipping the accelerometer.
    
    return;
    
    
    if(gamePaused == NO) {
        CGPoint pt = shipView.center;
        CGFloat accel = acceleration.x * kAccelerationSpeed;
        
        // Horizontal ship control
        if(pt.x - halfShipWidth + accel > 0 && pt.x + halfShipWidth + accel < 320) {
            pt.x += accel;
        }
        
        [shipView setCenter:pt];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // User taps screen, pause game and display splash window with settings button
    [self displayHideSplashScreen];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.adBannerView = nil;

}

//- (void)dealloc {	
//    //	[enemyArray release];
//    //	[bonusArray release];
//    //	[scoreLabel release];
//    self.adBannerView = nil;
//    
//    [super dealloc];
//}

















#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}

- (void)subscribeToInfo
{
    NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    // note: this doesn't work right.
    err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
}

- (void)startFreeFallResetTimer
{
	// currrently free fall is only reported as info indicating isInFreeFall, immediately followed by info indicating !isInFreeFall (during is not yet supported)
	// so to make sure the user sees a visual indication of the device having been in/is in free fall, a timer is used to display "Free Fall? yes" for three seconds.
	
	[self stopFreeFallResetTimer];
	self.freeFallResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(freeFallResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopFreeFallResetTimer
{
	if ([self.freeFallResetTimer isValid]) {
		[self.freeFallResetTimer invalidate];
		self.freeFallResetTimer = nil;
	}
}

//- (void)freeFallResetTimer:(NSTimer *)theTimer
//{
//	self.freeFallLabel.text = @"no";
//}

- (void)startTapsResetTimer
{
	// since taps are only reported in one brief info update, a timer is used to display the most recent taps for three seconds.
	
	[self stopTapsResetTimer];
	self.tapsResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(tapsResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopTapsResetTimer
{
	if ([self.tapsResetTimer isValid]) {
		[self.tapsResetTimer invalidate];
		self.tapsResetTimer = nil;
	}
}

//- (void)tapsResetTimer:(NSTimer *)theTimer
//{
//	self.tapsLabel.text = @"-";
//}

- (IBAction)calibrateOrientationButton:(id)sender
{
	// zero's orientation tracking
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
    
    [self subscribeToInfo];
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver
- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
    // ANIL COMMENTED	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
    
    float range = 0.2;
    
    
    if(gamePaused == NO) {
        
        if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
            PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
            
            CGPoint pt = shipView.center;
            //            CGFloat accel = (eulerAngles.z + 180.0)/360.0;
            CGFloat accel = ((eulerAngles.z + 180.0)/360.0);
            if (accel<(0.5-range*0.5)) {
                accel = 0.5-range*0.5;
            }
            if (accel>0.5+range*0.5) {
                accel=0.5+range*0.5;
            }
            accel -= 0.5-range*0.5;
            accel /= range;
            accel *= (self.view.frame.size.width - halfShipWidth*2);
            accel += halfShipWidth;
            
            NSLog(@"Printing accel = %f", accel );
            
            //        CGFloat accel = acceleration.x * kAccelerationSpeed;
            
            // Horizontal ship control
            //if(pt.x - halfShipWidth + accel > 0 && pt.x + halfShipWidth + accel < 320) {
                pt.x = accel;
            //}
            
            [shipView setCenter:pt];
        }
    }
}




- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo2:(PLTInfo *)theInfo
{
// ANIL COMMENTED	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
    
    
    
    
    if(gamePaused == NO) {
        
        if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
            PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
        
            CGPoint pt = shipView.center;
//            CGFloat accel = (eulerAngles.z + 180.0)/360.0;
            CGFloat accel = (((eulerAngles.z + 180.0)/360.0)-0.5)*40.0;

            NSLog(@"Printing accel = %f", accel );

//        CGFloat accel = acceleration.x * kAccelerationSpeed;
        
        // Horizontal ship control
        if(pt.x - halfShipWidth + accel > 0 && pt.x + halfShipWidth + accel < 320) {
            pt.x += accel;
        }
        
        [shipView setCenter:pt];
    }

    
    
    //
    //	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
    //         PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
    //         self.headingLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.x)];
    //         [self.headingProgressView setProgress:(eulerAngles.x + 180.0)/360.0 animated:YES];
    //         self.pitchLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.y)];
    //         [self.pitchProgressView setProgress:(eulerAngles.y + 180.0)/360.0 animated:YES];
    //         self.rollLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.z)];
    //         [self.rollProgressView setProgress:(eulerAngles.z + 180.0)/360.0 animated:YES];
    //	}
    //	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
    //		self.wearingStateLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
    //	}
    //	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
    //		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
    //		self.mobileProximityLabel.text = NSStringFromProximity(proximityInfp.mobileProximity);
    //		self.pcProximityLabel.text = NSStringFromProximity(proximityInfp.pcProximity);
    //	}
    //	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
    //		self.pedometerLabel.text = [NSString stringWithFormat:@"%u", ((PLTPedometerInfo *)theInfo).steps];
    //	}
    //	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
    //		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
    //		if (isInFreeFall) {
    //			self.freeFallLabel.text = (isInFreeFall ? @"yes" : @"no");
    //			[self startFreeFallResetTimer];
    //		}
    //	}
    //	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
    //		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
    //		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
    //		self.tapsLabel.text = [NSString stringWithFormat:@"%u in %@", tapsInfo.taps, directionString];
    //		[self startTapsResetTimer];
    //	}
    //	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
    //		self.magnetometerCalLabel.text = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no");
    //	}
    //	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
    //		self.gyroscopeCalLabel.text = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" );
    //	}

    
    
//	
//	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
//         PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
//         self.headingLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.x)];
//         [self.headingProgressView setProgress:(eulerAngles.x + 180.0)/360.0 animated:YES];
//         self.pitchLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.y)];
//         [self.pitchProgressView setProgress:(eulerAngles.y + 180.0)/360.0 animated:YES];
//         self.rollLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.z)];
//         [self.rollProgressView setProgress:(eulerAngles.z + 180.0)/360.0 animated:YES];
//	}
//	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
//		self.wearingStateLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
//	}
//	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
//		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
//		self.mobileProximityLabel.text = NSStringFromProximity(proximityInfp.mobileProximity);
//		self.pcProximityLabel.text = NSStringFromProximity(proximityInfp.pcProximity);
//	}
//	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
//		self.pedometerLabel.text = [NSString stringWithFormat:@"%u", ((PLTPedometerInfo *)theInfo).steps];
//	}
//	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
//		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
//		if (isInFreeFall) {
//			self.freeFallLabel.text = (isInFreeFall ? @"yes" : @"no");
//			[self startFreeFallResetTimer];
//		}
//	}
//	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
//		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
//		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
//		self.tapsLabel.text = [NSString stringWithFormat:@"%u in %@", tapsInfo.taps, directionString];
//		[self startTapsResetTimer];
//	}
//	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
//		self.magnetometerCalLabel.text = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no");
//	}
//	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
//		self.gyroscopeCalLabel.text = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" );
//	}
}
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (DEVICE_IPAD) self = [super initWithNibName:@"ViewController_iPad" bundle:nil];
    else self = [super initWithNibName:@"ViewController_iPhone" bundle:nil];
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

@end
