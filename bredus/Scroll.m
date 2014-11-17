//
//  Scroll.m
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "Scroll.h"

@implementation Scroll

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self.delegate postionChanged:self];
}

@end
