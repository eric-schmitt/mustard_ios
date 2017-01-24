//
//  Event+CoreDataProperties.h
//  Mustard
//
//  Created by Eric Schmitt on 6/6/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSString *entId;
@property (nullable, nonatomic, retain) NSNumber *forcedNoTracking;
@property (nullable, nonatomic, retain) NSNumber *forcedTracking;
@property (nullable, nonatomic, retain) NSNumber *hasArrived;
@property (nullable, nonatomic, retain) NSNumber *hasJoined;
@property (nullable, nonatomic, retain) NSNumber *isFinished;
@property (nullable, nonatomic, retain) NSNumber *isNow;
@property (nullable, nonatomic, retain) NSNumber *isOwner;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSString *link;
@property (nullable, nonatomic, retain) NSString *locationName;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *startTracking;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<Message *> *messages;
@property (nullable, nonatomic, retain) NSSet<Person *> *persons;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet<Message *> *)values;
- (void)removeMessages:(NSSet<Message *> *)values;

- (void)addPersonsObject:(Person *)value;
- (void)removePersonsObject:(Person *)value;
- (void)addPersons:(NSSet<Person *> *)values;
- (void)removePersons:(NSSet<Person *> *)values;

@end

NS_ASSUME_NONNULL_END
