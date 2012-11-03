//
//  TexureManager.h
//  TexurePackerForCocoa
//
//  Created by demon on 9/5/12.
//  Copyright (c) 2012 demon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TexureManager : NSObject
{
    NSMutableDictionary * texureDic;
}

+(TexureManager*)shareInstance;
+(UIImage*)createImageFrom:(CGImageRef)source
          destinationWidth:(NSUInteger)width
         destinationHeight:(NSUInteger)height
                    offset:(CGPoint)offset
                     scale:(int)scale
               orientation:(UIImageOrientation)orientation;
-(void)addTextureFile:(NSString*)fileName isRetina:(BOOL)retina;
-(UIImage*)getUIImageByName:(NSString*)imageName;
-(NSArray*)getAllImages;

@end
