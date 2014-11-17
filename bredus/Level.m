//
//  Level.m
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "Level.h"
#import "Rebus.h"
#import "CCDirector.h"
#import "cocos2d.h"

@implementation Level
{
    CGPoint previousTouchLocation;
    float touchDistance;
    Rebus *_touchStartedOnRebus;
}
+(Level *)levelWithNumber:(int)number_
{
    Level *level = [Level node];
    level.number = number_;
    [level fillWithRebuses];
    level.touchEnabled = YES;
    
    return level;
}

-(void)fillWithRebuses
{
    CGSize win_size = [CCDirector sharedDirector].winSize;
    int line_number = 0;
    for (int i = 1; i <= 8; i++)
    {
        Rebus *rebus = [Rebus rebusWithNumber:i+(((self.number % 2) == 0) ? 8 : 0)];
        [self addChild:rebus];
        rebus.startScale = (win_size.width / 3.5) / rebus.contentSize.width;
        float x_pos = win_size.width * 0.5 + rebus.contentSize.width * rebus.scale / 2.0 * (((i % 2) == 0) ? 1 : -1);
        float y_pos = win_size.height - ((win_size.height * 0.5 - rebus.contentSize.height * rebus.scale * 2) + rebus.contentSize.height * rebus.scale * line_number) - rebus.contentSize.height * rebus.scale * 0.5;
        rebus.startPosition = CGPointMake(x_pos, y_pos);
        rebus.tag = i;

        [rebus setBlurSize:0.95];
        
        if ((i % 2) == 0)
        {
            line_number++;
        }
    }
}

-(void)checkBluredTextures
{
    CGSize win_size = [CCDirector sharedDirector].winSize;
    for (Rebus *rebus in [self children]) {
        if (rebus.isBig) {
            [rebus setBlurSize:0];
            continue;
        }
        CGPoint global_rebus_position = [rebus.parent convertToWorldSpace:rebus.position];
        if (((global_rebus_position.x + rebus.contentSize.width * rebus.scale * 0.5) < 0) ||
            ((global_rebus_position.x - rebus.contentSize.width * rebus.scale * 0.5) > win_size.width))
        {
//            rebus.visible = NO;
        }
        else if (((global_rebus_position.x - rebus.contentSize.width * rebus.scale * 0.5) > 0) &&
                 ((global_rebus_position.x + rebus.contentSize.width * rebus.scale * 0.5) < win_size.width))
        {
//            rebus.visible = YES;
            [rebus setBlurSize:0];
        }
        else
        {
//            rebus.visible = YES;
            [rebus setBlurSize:0.99];
        }
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    previousTouchLocation = location;
    
    touchDistance = 0;
    
    _touchStartedOnRebus = nil;
    for (Rebus *rebus in [self children])
    {
        if ([rebus isInTouchPosition:location])
        {
            _touchStartedOnRebus = rebus;
            break;
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    touchDistance += ccpDistance(location, previousTouchLocation);
    if (touchDistance > 20)
    {
        _touchStartedOnRebus = nil;
    }
    previousTouchLocation = location;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    Rebus *touchEndOnRebus = nil;
    for (Rebus *rebus in [self children])
    {
        if ([rebus isInTouchPosition:location])
        {
            touchEndOnRebus = rebus;
            break;
        }
    }
    
    if (touchEndOnRebus && touchEndOnRebus == _touchStartedOnRebus)
    {
        if (!touchEndOnRebus.isBig)
        {
            [self showRebus:touchEndOnRebus];
        }
        else
        {
            [self hideRebus:touchEndOnRebus];
        }
    }
}

-(void)showRebus:(Rebus *)rebus_
{
    self.layer.isBigPictureShown = YES;
    float action_duration = 0.3;
    float action_distance = [CCDirector sharedDirector].winSize.height;
    
    int side_rebus_id = (rebus_.number % 2 == 0) ? rebus_.number - 1: rebus_.number + 1;
    
    // кто летит вверх
    for (int i = 1; i < MIN(rebus_.number, side_rebus_id); i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x, rebus.position.y + action_distance)];
        [rebus runAction:move_up];
    }
    
    // кто летит влево
    for (int i = side_rebus_id; i < rebus_.number; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x - action_distance, rebus.position.y)];
        [rebus runAction:move_up];
    }
    
    // кто летит вправо
    for (int i = rebus_.number + 1; i <= side_rebus_id; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x + action_distance, rebus.position.y)];
        [rebus runAction:move_up];
    }
    
    // кто летит вниз
    for (int i = MAX(rebus_.number, side_rebus_id) + 1; i <= 8; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x, rebus.position.y - action_distance)];
        [rebus runAction:move_up];
    }
    
    // scale me
    [rebus_ zoomOut];

}

-(void)hideRebus:(Rebus *)rebus_
{
    self.layer.isBigPictureShown = NO;
    float action_duration = 0.3;
    float action_distance = [CCDirector sharedDirector].winSize.height;
    
    int side_rebus_id = (rebus_.number % 2 == 0) ? rebus_.number - 1: rebus_.number + 1;
    
    // кто летит вверх
    for (int i = 1; i < MIN(rebus_.number, side_rebus_id); i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x, rebus.position.y - action_distance)];
        [rebus runAction:move_up];
    }
    
    // кто летит влево
    for (int i = side_rebus_id; i < rebus_.number; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        rebus.visible = YES;
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x + action_distance, rebus.position.y)];
        [rebus runAction:move_up];
    }
    
    // кто летит вправо
    for (int i = rebus_.number + 1; i <= side_rebus_id; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        rebus.visible = YES;
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x - action_distance, rebus.position.y)];
        [rebus runAction:move_up];
    }
    
    // кто летит вниз
    for (int i = MAX(rebus_.number, side_rebus_id) + 1; i <= 8; i++) {
        Rebus *rebus = (Rebus *)[self getChildByTag:i];
        CCMoveTo *move_up = [CCMoveTo actionWithDuration:action_duration position:CGPointMake(rebus.position.x, rebus.position.y + action_distance)];
        [rebus runAction:move_up];
    }
    
    // scale me
    [rebus_ zoomIn];
    
}


@end
