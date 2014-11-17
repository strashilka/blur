//
//  HelloWorldLayer.h
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright admin 2014. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>//CCLayer
{
    
}

@property(nonatomic)BOOL isBigPictureShown;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)postionChanged:(CCNode *)node;


@end
