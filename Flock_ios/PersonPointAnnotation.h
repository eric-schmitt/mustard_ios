//
//  PersonPointAnnotation.h
//  Mustard
//
//  Created by Eric Schmitt on 4/22/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Person.h"

@interface PersonPointAnnotation : MKPointAnnotation

@property Person *person;

@end
