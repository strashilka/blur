//
//  Level.h
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "CCSprite.h"
#import "CCLayer.h"
#import "HelloWorldLayer.h"

@interface Level : CCLayer

@property (nonatomic)int number;
@property (nonatomic, assign)HelloWorldLayer *layer;

+(Level *)levelWithNumber:(int)number_;
-(void)checkBluredTextures;
@end
