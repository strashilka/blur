//
//  HelloWorldLayer.m
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright admin 2014. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "Level.h"
#import "Scroll.h"
#import "CCRenderTexture.h"
#import "TextureBlur.h"

@interface HelloWorldLayer()
{
    CGPoint firstTouch;
    CGPoint previousTouch;
    CGPoint lastTouch;
    
    Scroll *_scroll;
    CCSprite *_background;
    CCSprite *_plus;
    float backgroundVelocityRatio;
    int levelsCount;
    
    CGFloat touchDistance;
    BOOL isTouchStartedOnPlus;
    
    CCLayer *window;
    BOOL isWindowVisible;
}


@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [[HelloWorldLayer alloc] init];
	
	// add layer as a child to scene
	[scene addChild: layer];
    [layer release];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
//		// create and initialize a Label
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
//
//		// ask director for the window size
//		CGSize size = [[CCDirector sharedDirector] winSize];
//	
//		// position the label on the center of the screen
//		label.position =  ccp( size.width /2 , size.height/2 );
//		
//		// add the label as a child to this Layer
//		[self addChild: label];
        isWindowVisible = false;
        levelsCount = 8;
        backgroundVelocityRatio = 0.3f;

        [self createBackground];
        [self createLevels];
        
        self.touchEnabled = YES;
        

        
        window = [CCLayer node];
        [self addChild:window];
        [self hideWindow];
        
	}
	return self;
}

-(void)completionCallback:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fullFileName = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCSprite *sprite = [CCSprite spriteWithFile:fullFileName];
    sprite.color = ccGRAY;
    [window addChild:sprite z:-1];
    sprite.position = CGPointMake(screenSize.width * 0.5, screenSize.height * 0.5);
    [_scroll getChildByTag:[self currentLevelNumber]].visible = NO;
}

-(void)createBackground
{
    _background = [CCSprite node];
    _background.anchorPoint = ccp(0, 0);
    [self addChild:_background];
    
    CCSprite *back = [CCSprite spriteWithFile:@"Texture.png"];
    back.scale = [CCDirector sharedDirector].winSize.height / back.contentSize.height;
    back.anchorPoint = ccp(0, 0);
    back.tag = 1;
    [_background addChild:back];
    
    CGSize win_size = [CCDirector sharedDirector].winSize;
    int backs_count = ceil((win_size.width * levelsCount / (back.contentSize.width * back.scale)) * backgroundVelocityRatio) + 1;
    for (int i = 1; i < backs_count ; i ++)
    {
        CCSprite *back2 = [CCSprite spriteWithFile:@"Texture.png"];
        back2.scale = back.scale;
        back2.anchorPoint = ccp(0, 0);
        back2.tag = i + 1;
        back2.position = ccp(i + back.contentSize.width * back.scale, 0);
        [_background addChild:back2];
    }
}

-(void)createLevels
{
    _scroll = [Scroll node];
    _scroll.delegate = self;
    _scroll.anchorPoint = ccp(0, 0);
    [self addChild:_scroll];
    
    _plus = [CCSprite spriteWithFile:@"test_plus.png"];
    _plus.position = ccp(_plus.contentSize.width, [CCDirector sharedDirector].winSize.height - _plus.contentSize.width);
    [self addChild:_plus];
    
    for (int i = 1; i <= levelsCount; i++)
    {
        Level *level = [Level levelWithNumber:i];
        level.tag = i;
//        level.layer = self;
        level.position = ccp((i - 1) * [CCDirector sharedDirector].winSize.width, 0);
        [_scroll addChild:level];
    }
    
    _scroll.position = CGPointZero;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark - swipe
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isWindowVisible)
    {
        return;
    }
    
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 1
    firstTouch = location;
    previousTouch = location;
    
    touchDistance = 0;
    isTouchStartedOnPlus = [self isPlusInTouchPosition:location];
}

-(BOOL)isPlusInTouchPosition:(CGPoint)location
{
    CGRect bb = _plus.boundingBox;
    bb.origin = [_plus.parent convertToWorldSpace:_plus.boundingBox.origin];
    float increse_size = 20;
    bb.origin = ccpSub(bb.origin, ccp(increse_size,increse_size));
    bb.size = CGSizeMake(bb.size.width + increse_size * 2, bb.size.height + increse_size * 2);
    BOOL result = CGRectContainsPoint(bb, location);
    NSLog([NSString stringWithFormat:@"isPlusInTouchPosition %@", (result ? @"YES" : @"NO")]);
    return result;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isWindowVisible)
    {
        return;
    }
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    float delta = location.x - previousTouch.x;
    CGPoint destination_scroll_position = CGPointMake(_scroll.position.x + delta, _scroll.position.y);
    if (destination_scroll_position.x > 0)
    {
        destination_scroll_position.x = 0;
    }
    if (destination_scroll_position.x < -[CCDirector sharedDirector].winSize.width * (levelsCount - 1))
    {
        destination_scroll_position.x = -[CCDirector sharedDirector].winSize.width * (levelsCount - 1);
    }
    
    if (!self.isBigPictureShown)
    {
        _scroll.position = destination_scroll_position;
        _background.position = CGPointMake(destination_scroll_position.x * backgroundVelocityRatio, _background.position.y);
    }
//    [self checkBluredTextures];

    touchDistance += ccpDistance(previousTouch, location);
    previousTouch = location;

}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isWindowVisible)
    {
        [self hideWindow];
        return;
    }
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    
    //Check if the swipe is a left swipe and long enough
    if (firstTouch.x > lastTouch.x && swipeLength > 60) {
//        [self doStuff];
    }
    
    [self moveToLevel:[self currentLevelNumber]];
    if (touchDistance < 10 && isTouchStartedOnPlus && [self isPlusInTouchPosition:location])
    {
        [self showWindow];
    }
}

-(void)showWindow
{
    for (Level *level in _scroll.children) {
        level.touchEnabled = NO;
    }
    isWindowVisible = YES;
    NSString *fileName = [NSString stringWithFormat:@"blur_%i.png", (int)[[NSDate date] timeIntervalSince1970]];
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:[CCDirector sharedDirector].winSize.width
                                                           height:[CCDirector sharedDirector].winSize.height
                                                      pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
//    CCSprite *grey_layer = [CCSprite spriteWithFile:@"black.png"];
//    grey_layer.opacity = 30;
    CGSize screen_size = [CCDirector sharedDirector].winSize;
//    grey_layer.scale = MAX(screen_size.height, screen_size.width) / grey_layer.contentSize.width;
//    grey_layer.position = CGPointMake(screen_size.width * 0.5, screen_size.height * 0.5);
    [rt retain];
    [rt begin];
    
//    [[_background getChildByTag:1] visit];
//    [[_scroll getChildByTag:[self currentLevelNumber]] visit];
    [self visit];
//    [grey_layer visit];
    [rt end];
    
//    if ([[[CCFileUtils sharedFileUtils] fileManager] fileExistsAtPath:fullFileName])
//    {
//        [self completionCallback:fullFileName];
//    }
//    else
//    {
        [TextureBlur create:rt.sprite.texture radius:30 fileName:fileName callback:
         ^(NSString *file_name)
		 {
			 [self completionCallback:file_name];
		 }step:1];
//    }
    
    CCSprite *win = [CCSprite spriteWithFile:@"test_window.png"];
    win.position = CGPointMake(screen_size.width * 0.5, screen_size.height * 0.5);
    win.scale = screen_size.width * 0.8 / win.contentSize.width;
    [window addChild:win];
    
    window.visible = YES;
}

-(void)hideWindow
{
        [_scroll getChildByTag:[self currentLevelNumber]].visible = YES;
    isWindowVisible = NO;
    
    window.visible = NO;
    
    [window removeAllChildrenWithCleanup:YES];
    for (Level *level in _scroll.children) {
        level.touchEnabled = YES;
    }

}

-(void)checkBluredTextures
{
    int level = [self currentLevelNumber];
    for (int i = MAX(level - 1, 1); i <= level +1; i++) {
        Level *level = (Level *)[_scroll getChildByTag:i];
        if (level && [level isKindOfClass:[Level class]])
        {
            [level checkBluredTextures];
        }
    }
    
}

-(int)currentLevelNumber
{
    return abs(round(_scroll.position.x / [CCDirector sharedDirector].winSize.width)) + 1;
}

-(void)postionChanged:(CCNode *)node
{
    [self checkBluredTextures];
}

-(void)moveToLevel:(int)level_number_
{
    CGPoint desctination_position = CGPointMake((level_number_ - 1) * [CCDirector sharedDirector].winSize.width * (-1), 0);
    CCMoveTo *action = [CCMoveTo actionWithDuration:0.3 position:desctination_position];
    CCEaseOut *easy = [CCEaseOut actionWithAction:action rate:2];
    easy.tag = 77;
    [_scroll runAction:easy];
    
    desctination_position = CGPointMake((level_number_ - 1) * [CCDirector sharedDirector].winSize.width * backgroundVelocityRatio * (-1), 0);
    CCMoveTo *move_back = [CCMoveTo actionWithDuration:0.3 position:desctination_position];
    CCEaseIn *easy_back = [CCEaseIn actionWithAction:move_back rate:2];
    [_background runAction:easy_back];

}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
