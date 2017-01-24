//
//  UIColor+HexString.h
//  Mustard
//
//  Created by Eric Schmitt on 4/16/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
