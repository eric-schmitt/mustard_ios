//
//  MapPinAnnotation.m
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "MapPinAnnotation.h"

@implementation MapPinAnnotation

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                            person:(Person *)person;
{
    // The re-use identifier is always nil because these custom pins may be visually different from one another
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:nil];
    
    
    
/*
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.person = person;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:person.pictureURL]];
    UIImage *largeProfile = [UIImage imageWithData:imageData];
    
    CGRect rect = CGRectMake(0,0,25,32);
    UIGraphicsBeginImageContext( rect.size );
    [largeProfile drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *smallImage = UIImagePNGRepresentation(picture1);
    self.personImage = [UIImage imageWithData:smallImage];
    
    [self setNeedsDisplay];*/
    //Get Profile Picture here
    
    return self;
}


@end
