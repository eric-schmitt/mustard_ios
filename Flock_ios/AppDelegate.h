//
//  AppDelegate.h
//  Flock_ios
//
//  Created by Eric Schmitt on 4/5/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Person.h"
#import "LocationTracker.h"
#import "API.h"

#define EVENT_TIMEOUT 40*60
#define EVENT_HIDE 40*60*8
#define MESSAGE_BROADCAST @"messages_updated"
#define EVENT_BROADCAST @"event_updated"
#define EVENT_SYNCRONIZER_TOKEN @"event_syncronizer"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property float heading;

@property BOOL awaitingAuthForTracking;
@property BOOL trackingForEvent;
@property BOOL is24HourTime;
@property NSTimer *locationTimer;
@property NSDate *lateUpdateTime;
@property NSDate *nextStartTrackingTime;
@property NSArray *eventsTracking;
@property BOOL shouldOpenEvent;
@property Person *user;

@property (strong, nonatomic) LocationTracker* locationTracker;

- (BOOL)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(BOOL)checkForPermission;
-(void)checkForPermissionAndStartUpdating;
-(BOOL)checkTimesAndUpdateLocationTracker;
-(BOOL)shouldChangeToHighFrequency;
-(void)stopUpdatingLocation;
-(void)changeToList;
-(void)processLocation;
-(void)getEventsForTracking;
-(void)getNextEventForTracking;
-(void)processLocation:(id)sender;
-(void)updateLocation:(CLLocationCoordinate2D)location andHeading:(double) header;
-(void)sendMessage:(Message *)message;
-(void)updateLists;
-(void)updateSingleEvent:(Event *)localEvent withServerDictionary:(NSDictionary *)dictionary withPeople:(NSArray *)people;

@end

