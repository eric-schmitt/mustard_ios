//
//  MapPinAnnotation.h
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>
#import "Person.h"

@interface MapPinAnnotation : MKAnnotationView
@property Person *person;
@property UIImageView *backgroundPin;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                           person:(Person *)person;
@end
