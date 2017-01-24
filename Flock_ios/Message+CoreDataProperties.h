//
//  Message+CoreDataProperties.h
//  Mustard
//
//  Created by Eric Schmitt on 6/6/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateTime;
@property (nullable, nonatomic, retain) NSString *ent_id;
@property (nullable, nonatomic, retain) NSNumber *failed;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSNumber *successful;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) Person *person;

@end

NS_ASSUME_NONNULL_END
