//
//  TexureManager.m
//  TexurePackerForCocoa
//
//  Created by demon on 9/5/12.
//  Copyright (c) 2012 demon. All rights reserved.
//

#import "TexureManager.h"

#define ROOT_KEY                @"Root"
#define ATTRS_KEY               @"metadata"
    
#define FRAMES_KEY              @"frames"
#define FRAME_KEY               @"frame"
#define SCOURCE_COLOR_RECT      @"sourceColorRect"
#define SOURCE_SIZE             @"sourceSize"
#define OFFSET                  @"offset"

#define IMAGE_NAME_KEY          @"realTextureFileName"

typedef enum
{
    ALPHA   = 3,
    BLUE    = 2,
    GREEN   = 1,
    RED     = 0
} PIXELS;

static TexureManager * _instance;

@implementation TexureManager

- (void)dealloc
{
    [texureDic release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        texureDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(TexureManager*)shareInstance
{
    if(!_instance) _instance = [[TexureManager alloc] init];
    return  _instance;
}

-(void)addTextureFile:(NSString*)fileName isRetina:(BOOL)retina
{
    NSString * file         = [[NSBundle mainBundle] pathForResource:fileName
                                                              ofType:@"plist"];
    NSDictionary * dicRoot  = [NSDictionary dictionaryWithContentsOfFile:file];
    
    NSDictionary * atts     = [dicRoot objectForKey:ATTRS_KEY];
    
    UIImage * image         = [UIImage imageNamed:[atts objectForKey:IMAGE_NAME_KEY]];
    NSDictionary * frames   = [dicRoot objectForKey:FRAMES_KEY];
    
    int scale = retina?2:1;
    for (NSString *  key in [frames allKeys])
    {
        NSDictionary * keyDic= [frames objectForKey:key];
        
        NSString * frame                = [keyDic objectForKey:FRAME_KEY];
       
        NSString * sourceColorRectStr   = [keyDic objectForKey:SCOURCE_COLOR_RECT];
        //NSString * offsetStr            = [keyDic objectForKey:OFFSET];
        NSString * sourceSizeStr        = [keyDic objectForKey:SOURCE_SIZE];
        
        
        CGSize  sourceSize              = CGSizeFromString(sourceSizeStr); 
        CGRect  sourceColorRect         = CGRectFromString(sourceColorRectStr);
        CGRect  frameRect               = CGRectFromString(frame);
        
        NSUInteger destinationWidth     = (NSUInteger)sourceSize.width;
        NSUInteger destinationHeight    = (NSUInteger)sourceSize.height;
        
        BOOL is_orientation             = [[keyDic objectForKey:@"rotated"] boolValue];

        if(is_orientation)
        {   
            frameRect       = CGRectMake(frameRect.origin.x,
                                                     frameRect.origin.y,
                                                     frameRect.size.height,
                                                     frameRect.size.width);
            NSUInteger temp     = destinationWidth;
            destinationWidth    = destinationHeight;
            destinationHeight   =  temp;
        }
        
        CGImageRef ref =  CGImageCreateWithImageInRect(image.CGImage, frameRect);
        
        UIImageOrientation orientation = is_orientation?UIImageOrientationLeft:UIImageOrientationUp;

        UIImage * image = [TexureManager createImageFrom:ref 
                                        destinationWidth:destinationWidth
                                       destinationHeight:destinationHeight
                                                  offset:sourceColorRect.origin
                                                   scale:scale
                                             orientation:orientation];
        
        [texureDic setObject:image forKey:key];
        CGImageRelease(ref);
    }
}

+(UIImage*)createImageFrom:(CGImageRef)source
          destinationWidth:(NSUInteger)width
         destinationHeight:(NSUInteger)height
                    offset:(CGPoint)offset
                     scale:(int)scale
               orientation:(UIImageOrientation)orientation
{
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    uint32_t * be_painted_pixels = (uint32_t*)malloc(width*height*sizeof(uint32_t));
    memset(be_painted_pixels, 0, width*height*sizeof(uint32_t));
    
    NSInteger src_width    = CGImageGetWidth(source);
    NSInteger src_height   = CGImageGetHeight(source);
    
    uint32_t * sources = (uint32_t*)malloc(src_width*src_height*sizeof(uint32_t));
    memset(sources, 0, src_width*src_height*sizeof(uint32_t));
    
    CGContextRef context = CGBitmapContextCreate(sources,
                                                 src_width,
                                                 src_height,
                                                 8,
                                                 src_width*sizeof(uint32_t),
                                                 colorSpaceRef,
                                                 bitmapInfo);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, src_width, src_height),
                       source);
    
    
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x < width; x++)
        {
            uint8_t *paintedPixel   = (uint8_t *) &be_painted_pixels[y* width+x];
            
            paintedPixel[RED]      = 255;
            paintedPixel[GREEN]    = 0;
            paintedPixel[BLUE]     = 0;
            paintedPixel[ALPHA]    = 255;
        }
    }
    
    for(int y = 0; y < src_height; y++)
    {
        for(int x = 0; x < src_width; x++)
        {
            uint8_t *paintedPixel   = (uint8_t *) &be_painted_pixels[(y+(int)offset.y) * width + (int)offset.x+x];
            uint8_t *originPixel = (uint8_t *) &sources[y * src_width + x];
            
            paintedPixel[RED]      = originPixel[RED];
            paintedPixel[GREEN]    = originPixel[GREEN];
            paintedPixel[BLUE]     = originPixel[BLUE];
            paintedPixel[ALPHA]    = originPixel[ALPHA];
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              be_painted_pixels,
                                                              width*height*sizeof(uint32_t),
                                                              NULL);
    
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        32,
                                        4*width,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,NULL,NO,renderingIntent);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef 
                                            scale:scale 
                                      orientation:orientation];
    
    free(be_painted_pixels);
    free(sources);
    CFRelease(context);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    return newImage;
}

-(UIImage*)getUIImageByName:(NSString*)imageName
{
    return [texureDic objectForKey:imageName];
}

-(NSArray*)getAllImages
{
    return texureDic.allValues;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
