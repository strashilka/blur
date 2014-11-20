//
//  TextureBlur.h
//  bredus
//
//  Created by admin on 16.11.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "CCSprite.h"

@interface TextureBlur : NSObject

+(void)create:(CCTexture2D *)target radius:(int) radius fileName:(NSString *)fileName callback:(void (^)(NSString *file_name_))callback step:(int) step;

+(void)calculateGaussianWeightsForPoints:(int)points weight:(CGFloat *)weights;
+(CCGLProgram *)getBlurShader:(CGSize)pixelSize direction:(CGPoint)direction radius:(int)radius weight:(GLfloat *)weights;
//class TextureBlur
//{
//public:
//    static void create(cocos2d::Texture2D* target, const int radius, const std::string& fileName, std::function<void()> callback, const int step = 1);
//    
//private:
//    static void calculateGaussianWeights(const int points, float* weights);
//    static cocos2d::GLProgram* getBlurShader(cocos2d::Size pixelSize, cocos2d::Point direction, const int radius, float* weights);
//};

@end
