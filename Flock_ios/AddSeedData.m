//
//  AddSeedData.m
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddSeedData.h"

@implementation AddSeedData



+ (id)seedData {
    static AddSeedData *seedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        seedData = [[self alloc] init];
    });
    return seedData;
}

- (id)init {
    if (self = [super init]) {
        self.selectedPeople = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

-(void) clearData {
    self.seedName = nil;
    self.date = nil;
    self.eventLocation = nil;
    self.locationName = nil;
     self.selectedPeople = [[NSMutableArray alloc] initWithCapacity:1];
    self.eventLink = nil;
    self.isNow = [NSNumber numberWithBool:NO];
}

@end
