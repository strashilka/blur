//
//  TextureBlur.m
//  bredus
//
//  Created by admin on 16.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "TextureBlur.h"
#import "CCGLProgram.h"
#import "CCFileUtils.h"
#import "CCTexture2D.h"
#import "ccShaders.h"
#import "CCRenderTexture.h"

@implementation TextureBlur

static const int maxRadius = 64;

+(void)calculateGaussianWeightsForPoints:(int)points weight:(CGFloat *)weights
{
    float dx = 1.0f/(float)(points-1);
    float sigma = 1.0f/3.0f;
    float norm = 1.0f/(sqrtf(2.0f*M_PI)*sigma*points);
    float divsigma2 = 0.5f/(sigma*sigma);
    weights[0] = 1.0f;
    for (int i = 1; i < points; i++)
    {
        float x = (float)(i)*dx;
        weights[i] = norm*expf(-x*x*divsigma2);
        weights[0] -= 2.0f*weights[i];
    }
}

+(CCGLProgram *)getBlurShader:(CGSize)pixelSize direction:(CGPoint)direction radius:(int)radius weight:(GLfloat *)weights
{
    GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:@"blur.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    CCGLProgram *blur = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:fragSource];
    
    CHECK_GL_ERROR_DEBUG();
    [blur addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
    [blur addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
    [blur addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    
    CHECK_GL_ERROR_DEBUG();

    [blur link];
    CHECK_GL_ERROR_DEBUG();
    
    [blur updateUniforms];
    CHECK_GL_ERROR_DEBUG();
    
    GLuint pixelSizeLoc = glGetUniformLocation(blur.program, "pixelSize");
    [blur setUniformLocation:pixelSizeLoc withF1:pixelSize.width f2:pixelSize.height];

    GLuint directionLoc = glGetUniformLocation(blur.program, "direction");
    [blur setUniformLocation:directionLoc withF1:direction.x f2:direction.y];

    GLuint radiusLoc = glGetUniformLocation(blur.program, "radius");
    [blur setUniformLocation:radiusLoc withI1:radius];
    
    GLuint weightsLoc = glGetUniformLocation(blur.program, "weights");
    [blur setUniformLocation:weightsLoc with1fv:weights count:radius];
    
    return blur;
}

+(void)create:(CCTexture2D *)target radius:(int) radius fileName:(NSString *)fileName callback:(void (^)(CCTexture2D *text))callback step:(int) step
{
    NSAssert(target != nil, @"Null pointer passed as a texture to blur");
    NSAssert(radius <= maxRadius, @"Blur radius is too big");
    NSAssert(radius > 0, @"Blur radius is too small");
//    NSAssert(!fileName, @"File name can not be empty");
    NSAssert(step <= radius/2 + 1 , @"Step is too big");
    NSAssert((step > 0), @"Step is too small");
    
    CGSize textureSize = target.contentSizeInPixels;
    CGSize pixelSize = CGSizeMake((float)(step)/textureSize.width, (float)(step)/textureSize.height);
    int radiusWithStep = radius/step;
    
    GLfloat	weights[64];
    [self calculateGaussianWeightsForPoints:radiusWithStep weight:weights];
    
    CCSprite* stepX = [[CCSprite alloc] initWithTexture:target];
    stepX.position = CGPointMake(textureSize.width * 0.5, textureSize.height * 0.5);
    stepX.flipY = YES;
    CCGLProgram *blurX = [TextureBlur getBlurShader:pixelSize direction:CGPointMake(1.0, 0) radius:radiusWithStep weight:weights];
    [stepX setShaderProgram:blurX];

    CCRenderTexture *rtX = [[CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height] retain];
    [rtX begin];
    [stepX visit];
    [rtX end];

    CCSprite* stepY = [[CCSprite alloc] initWithTexture:rtX.sprite.texture];
    stepY.position = CGPointMake(textureSize.width * 0.5, textureSize.height * 0.5);
    stepY.flipY = YES;
    CCGLProgram *blurY = [TextureBlur getBlurShader:pixelSize direction:CGPointMake(0, 1.0) radius:radiusWithStep weight:weights];
    [stepY setShaderProgram:blurY];

    CCRenderTexture *rtY = [[CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height] retain];
    [rtY begin];
    [stepY visit];
    [rtY end];
    
//    [rtY saveToFile:fileName format:kCCImageFormatPNG];
    
	CGImageRef imageRef = [rtY newCGImage];
    CCTexture2D *tex = [[CCTexture2D alloc] initWithCGImage:imageRef resolutionType:kCCResolutionUnknown ];
    callback([tex autorelease]);
}


@end
