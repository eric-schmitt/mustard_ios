//
//  Event+CoreDataProperties.m
//  Mustard
//
//  Created by Eric Schmitt on 6/6/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event+CoreDataProperties.h"

@implementation Event (CoreDataProperties)

@dynamic datetime;
@dynamic entId;
@dynamic forcedNoTracking;
@dynamic forcedTracking;
@dynamic hasArrived;
@dynamic hasJoined;
@dynamic isFinished;
@dynamic isNow;
@dynamic isOwner;
@dynamic latitude;
@dynamic link;
@dynamic locationName;
@dynamic longitude;
@dynamic startTracking;
@dynamic title;
@dynamic messages;
@dynamic persons;

@end
