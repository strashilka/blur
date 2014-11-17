//
//  Rebus.m
//  bredus
//
//  Created by admin on 15.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "Rebus.h"
#import "CGPointExtension.h"
#import "CCGLProgram.h"
#import "CCFileUtils.h"
#import "ccShaders.h"
#import "OpenGL_Internal.h"
#import "CCDirector.h"
#import "cocos2d.h"


static float zoom_duration = 0.3;

@interface Rebus()
{
	CGPoint blur_;
	GLfloat	sub_[4];
    
	GLuint	blurLocation;
	GLuint	subLocation;
}

@property(nonatomic)int number;
-(void) setBlurSize:(CGFloat)f;

@end

@implementation Rebus

@synthesize number = _number;

+(Rebus *)rebusWithNumber:(int)number_
{
    Rebus *r = [Rebus spriteWithFile:[NSString stringWithFormat:@"img-%02d.png", number_]];
    r.number = (number_ > 8) ? number_ - 8 : number_;
    return r;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {

		CGSize s = [self.texture contentSizeInPixels];
        
		blur_ = ccp(1/s.width, 1/s.height);
		sub_[0] = sub_[1] = sub_[2] = sub_[3] = 0;
        
		GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:@"simple_blur.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
		self.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:fragSource];
        
		CHECK_GL_ERROR_DEBUG();
        
		[self.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
		[self.shaderProgram addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
		[self.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
		CHECK_GL_ERROR_DEBUG();
        
		[self.shaderProgram link];
        
		CHECK_GL_ERROR_DEBUG();
        
		[self.shaderProgram updateUniforms];
        
		CHECK_GL_ERROR_DEBUG();
        
		subLocation = glGetUniformLocation( self.shaderProgram.program, "substract");
		blurLocation = glGetUniformLocation( self.shaderProgram.program, "blurSize");
        
		CHECK_GL_ERROR_DEBUG();

        
	}
    
	return self;
}

-(void) draw
{
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
	ccBlendFunc blend = self.blendFunc;
	ccGLBlendFunc( blend.src, blend.dst );
    
	[self.shaderProgram use];
	[self.shaderProgram setUniformsForBuiltins];
	[self.shaderProgram setUniformLocation:blurLocation withF1:blur_.x f2:blur_.y];
	[self.shaderProgram setUniformLocation:subLocation with4fv:sub_ count:1];
    
	ccGLBindTexture2D(  [self.texture name] );
    
	//
	// Attributes
	//
#define kQuadSize sizeof(_quad.bl)
	long offset = (long)&_quad;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}

-(void)setStartPosition:(CGPoint)startPosition
{
    _startPosition = startPosition;
    [super setPosition:startPosition];
}

-(void)setStartScale:(float)startScale
{
    _startScale = startScale;
    [super setScale:startScale];
}

-(void) setBlurSize:(CGFloat)f
{
    if (f == 0)
    {
        blur_ = CGPointZero;
    }
    else
    {
        blur_ =  ccp(0.01, 0.01);
    }
//	CGSize s = [self.texture contentSizeInPixels];
//    
//	blur_ = ccp(1/s.width, 1/s.height);
//	blur_ = ccpMult(blur_,f);
}

-(BOOL)isInTouchPosition:(CGPoint)location
{
    CGRect bb = self.boundingBox;
    bb.origin = [self.parent convertToWorldSpace:self.boundingBox.origin];
    BOOL result = CGRectContainsPoint(bb, location);
    return result;
}

-(void)zoomOut
{
    [self setBlurSize:0];
    _isBig = YES;
    
    CGPoint destination_point = CGPointMake([CCDirector sharedDirector].winSize.width * 0.5, [CCDirector sharedDirector].winSize.height * 0.5);
    CCMoveTo *move_action = [CCMoveTo actionWithDuration:zoom_duration position:destination_point];
    CCScaleTo *scale_action = [CCScaleTo actionWithDuration:zoom_duration scale:[CCDirector sharedDirector].winSize.width / self.contentSize.width];

    [self runAction:move_action];
    [self runAction:scale_action];

//    CCSequence *sequense = [CCSequence actions:move_action, scale_action, nil];
//    [self runAction:sequense];
}

-(void)zoomIn
{
    [self setBlurSize:0];
    _isBig = NO;
    
    CCMoveTo *move_action = [CCMoveTo actionWithDuration:zoom_duration position:self.startPosition];
    CCScaleTo *scale_action = [CCScaleTo actionWithDuration:zoom_duration scale:self.startScale];
    
    [self runAction:move_action];
    [self runAction:scale_action];
    
//    CCSequence *sequense = [CCSequence actions:scale_action, move_action, nil];
//    [self runAction:sequense];
}

@end
