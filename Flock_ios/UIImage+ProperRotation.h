//
//  UIImage+ProperRotation.h
//  Mustard
//
//  Created by Eric Schmitt on 7/20/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ProperRotation)

+ (UIImage *)scaleAndRotateImage:(UIImage *) image;

@end
