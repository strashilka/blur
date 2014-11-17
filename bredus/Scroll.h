//
//  Scroll.h
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "CCSprite.h"
#import "HelloWorldLayer.h"

@interface Scroll : CCSprite

@property(nonatomic, assign)HelloWorldLayer *delegate;

@end
