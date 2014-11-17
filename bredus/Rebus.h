//
//  Rebus.h
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "CCSprite.h"

@interface Rebus : CCSprite

@property(nonatomic,readonly)int number;
@property(nonatomic,readonly)BOOL isBig;
@property(nonatomic)CGPoint startPosition;
@property(nonatomic)float startScale;

+(Rebus *)rebusWithNumber:(int)number_;
-(void) setBlurSize:(CGFloat)f;
-(BOOL)isInTouchPosition:(CGPoint)location;
-(void)zoomOut;
-(void)zoomIn;


@end
