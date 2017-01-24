//
//  AddSeedData.h
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AddSeedData : NSObject

@property NSString *seedName;
@property NSDate *date;
@property CLLocation *eventLocation;
@property NSString *locationName;
@property (strong, nonatomic) NSMutableArray *selectedPeople;
@property NSString *eventLink;
@property NSNumber* isNow;

+ (id)seedData;

-(void)clearData;

@end
