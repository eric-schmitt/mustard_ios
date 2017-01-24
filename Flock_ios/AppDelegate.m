//
//  AppDelegate.m
//  Flock_ios
//
//  Created by Eric Schmitt on 4/5/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#define BACKGROUND_PROC_INTERVAL 10
#define IS_IN_PROXIMITY_DISTANCE 0.05f

#define EVENT_TEST_TYPE 4



#import "AppDelegate.h"
#import <Google/Analytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Person.h"
#import "Event.h"
#import "Message.h"
#import "JoinSeedViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "appirater/Appirater.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //self.locationManager = [[CLLocationManager alloc] init];
	

	[Fabric with:@[[Crashlytics class]]];
	[[Fabric sharedSDK] setDebug: YES];
	
	NSError *configureError;
	[[GGLContext sharedInstance] configureWithError:&configureError];
	NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
	
	// Optional: configure GAI options.
	GAI *gai = [GAI sharedInstance];
	//gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
	gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    self.eventsTracking = [NSMutableArray arrayWithCapacity:1];
    //[self.locationManager setDelegate:self];
    self.heading = -1;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:currentLocale];
    
    if([dateFormat rangeOfString:@"a"].location == NSNotFound) {
        self.is24HourTime = YES;
    } else {
        self.is24HourTime = NO;
    }
    
    if(self.locationTracker== nil) {
        self.locationTracker = [[LocationTracker alloc] init];
    }
    
    
    [self updateUser];
    
    //[self updateLists];
    
    [self getEventsForTracking];
	
	[Appirater setAppId:@"1"];
	[Appirater setDaysUntilPrompt:-1];
	[Appirater setUsesUntilPrompt:10];
	[Appirater setSignificantEventsUntilPrompt:-1];
	[Appirater setTimeBeforeReminding:5];
	[Appirater setDebug:NO];
	[Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    /*
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        /*self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                              target:self
                                                            selector:@selector(processLocation:)
                                                            userInfo:nil
                                                             repeats:NO];
       /* self.locationTracker = [[LocationTracker alloc] init];
        NSTimeInterval time = 60.0;
        self.locationTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
        
    }*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
    
    [self getEventsForTracking];
	
	if(self.locationTracker != nil) {
		self.locationTracker.servicesDisabledErrorShown = false;
	}
	
	[Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    NSString *urlProtocol = [url scheme];
    if([urlProtocol isEqualToString:@"mustard"] && self.user != nil) {
        NSString *eventID = [url host];
        NSLog(@"Attempting to open: %@", eventID);
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        JoinSeedViewController *controller = (JoinSeedViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"JoinSeed"];
        controller.eventStringID = eventID;
        controller.needsRequest = YES;
        
        [navigationController pushViewController:controller animated:YES];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}



#pragma mark - Location




-(void)checkForPermissionAndStartUpdating {
    self.awaitingAuthForTracking = true;
    [self startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if(self.eventsTracking.count > 0) {

        if([self.lateUpdateTime timeIntervalSince1970] - 10 > [[NSDate date] timeIntervalSince1970]) {
            //Send location update
            
            self.lateUpdateTime = [NSDate date];
            
            NSMutableArray *eventsToSendUpdates = [NSMutableArray arrayWithCapacity:1];

            
            for(Event *event in self.eventsTracking) {
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[event.latitude doubleValue] longitude:[event.longitude doubleValue]];
                CLLocationDistance distance = [locA distanceFromLocation:newLocation];
                
                if(distance < 0.1) {
                    [event setHasArrived:[NSNumber numberWithBool:YES]];
                    [self saveContext];
                } else {
                    [eventsToSendUpdates addObject:event];
                }
                
                if([self isInProximityForEvent:event :newLocation] || [event.datetime timeIntervalSince1970] < [[[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT] timeIntervalSince1970]) {
                    [self finishEvent:event];
                }
                
            }
        }
    }
}


-(void)updateLocation:(CLLocationCoordinate2D)location andHeading:(double) heading{
   
    if(self.eventsTracking.count > 0) {
        
        
        
            CLLocation *locationObj = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
            
            self.lateUpdateTime = [NSDate date];
            
            NSMutableArray *eventsToSendUpdates = [NSMutableArray arrayWithCapacity:1];
            
            
            for(Event *event in self.eventsTracking) {
                
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[event.latitude doubleValue] longitude:[event.longitude doubleValue]];
                CLLocationDistance distance = [locA distanceFromLocation:locationObj];
				
				if([event.hasArrived boolValue]) {
					continue;
				}
				
                if(distance < 0.1) {
                    [event setHasArrived:[NSNumber numberWithBool:YES]];
                    [self saveContext];
                }
				
				[eventsToSendUpdates addObject:[event entId]];
				
				double eventTime = [[event datetime] timeIntervalSince1970];
				double timeOut = [[[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT] timeIntervalSince1970];
				
                if([self isInProximityForEvent:event :locationObj] || [[event datetime] timeIntervalSince1970]<[[[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT] timeIntervalSince1970]) {
                    [self finishEvent:event];
                }
           }
            
        [[API sharedAPI] sendUpdateLocationForUserId:[self.user entId] lat:[NSNumber numberWithDouble:location.latitude] lon:[NSNumber numberWithDouble:location.longitude] heading:[NSNumber numberWithFloat:heading] seeds:[eventsToSendUpdates copy] completion:nil];
    }
}

#pragma mark - User

-(void)updateUser {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"isUser == true"];
    NSError *error;
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if(result != nil && result.count > 0) {
        self.user = [result objectAtIndex:0];
    } else {
        self.user = nil;
    }
}

#pragma mark - Messages
-(void)sendMessage:(Message *)message {

    [[API sharedAPI] sendStatus:self.user.entId withSeedID:message.event.entId withMessage:message.message completion:^(APIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Message *messageOnMain = [self.managedObjectContext objectWithID:[message objectID]];
            
            if((response.code == 200 || response.code == 204) && response.responseDictionary != nil && [response.responseDictionary objectForKey:@"statusTime"] != nil) {
                
                NSNumber *statusTime = [response.responseDictionary objectForKey:@"statusTime"];
                double timeStamp = [statusTime doubleValue];
                [message setDateTime:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
                 [message setFailed:[NSNumber numberWithBool:NO]];
                 [message setSuccessful:[NSNumber numberWithBool:YES]];
             } else {
                 [message setFailed:[NSNumber numberWithBool:YES]];
                 [message setSuccessful:[NSNumber numberWithBool:NO]];
             }
            
            [self saveContext];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_BROADCAST
                                                                object:nil];
        });
    }];
}

#pragma mark - Updater!
-(void)updateLists {
    @synchronized (self) {
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        
        NSNumber *lastUpdate;
        if([defaults objectForKey:@"last_update"] != nil) {
            lastUpdate = [defaults objectForKey:@"last_update"];
        } else {
            lastUpdate = [NSNumber numberWithInteger:0];
        }
        
        [[API sharedAPI] sendGetSeedsForUserId:[self.user entId] lastUpdate:lastUpdate completion:^(APIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{

                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
				
                request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
                NSError *error = nil;
                NSArray *events = [self.managedObjectContext executeFetchRequest:request error:&error];
                
                if ([response.responseDictionary objectForKey:@"statusTime"] != nil) {
                    NSNumber *statusTime = [response.responseDictionary objectForKey:@"statusTime"];
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    [defaults setObject:statusTime forKey:@"last_update"];
                }
                
                if ([response.responseDictionary objectForKey:@"seeds"] != nil) {

                    NSArray *serverEventsUnsorted = [response.responseDictionary objectForKey:@"seeds"];
                    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES];
                    
                    NSArray *serverEvents = [serverEventsUnsorted sortedArrayUsingDescriptors:@[descriptor]];
                    
                    for (NSDictionary *dictionary in serverEvents) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"entId == %@", [dictionary objectForKey:@"id"]];
                        NSArray *objects = [events filteredArrayUsingPredicate:predicate];
						
                        if(objects.count > 0) {
                            Event *localEvent = [objects objectAtIndex:0];
                            NSArray *people = [[localEvent persons] allObjects];
                            [self updateSingleEvent:localEvent withServerDictionary:dictionary withPeople:people];
                            
                        }
                    }
                }
                
                
                if([self saveContext]) {
                    
                    if([response.responseDictionary valueForKey:@"datetime"]!= nil) {
                        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                        [defaults setObject:[response.responseDictionary valueForKey:@"datetime"] forKey:@"last_update"];
                     }
                    
                    [self getEventsForTracking];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_BROADCAST
                                                                        object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BROADCAST
                                                                        object:nil];
                }
                
                
            });
        }];
    }
    
}

-(void)updateSingleEvent:(Event *)localEvent withServerDictionary:(NSDictionary *)dictionary withPeople:(NSArray *)people {
    if([dictionary objectForKey:@"title"] != nil) {
        localEvent.title = [dictionary objectForKey:@"title"];
    }
    if([dictionary objectForKey:@"locationName"] != nil) {
        localEvent.locationName = [dictionary objectForKey:@"locationName"];
    }
    if([dictionary objectForKey:@"location"] != nil) {
        NSDictionary *latLong = [dictionary objectForKey:@"location"];
        
        if([latLong objectForKey:@"latitude"] != nil) {
            localEvent.latitude = [latLong objectForKey:@"latitude"];
        }
        if([latLong objectForKey:@"longitude"] != nil) {
            localEvent.longitude = [latLong objectForKey:@"longitude"];
        }

    }
    
    if([dictionary objectForKey:@"datetime"] != nil) {
		
		if(localEvent.datetime.timeIntervalSince1970 != [[dictionary objectForKey:@"datetime"] doubleValue]) {
			localEvent.datetime = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"datetime"] doubleValue]];
	
			
			NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
			for (UILocalNotification *notification in notificationArray) {
				NSDictionary *userInfo = notification.userInfo;
				NSString *identifier = [userInfo valueForKey:@"eventId"];
				
				if([identifier isEqualToString:localEvent.entId]) {
					
					UILocalNotification* n2 = [[UILocalNotification alloc] init];
					
					n2.userInfo = notification.userInfo;
					n2.alertTitle = notification.alertTitle;
					n2.alertBody = notification.alertBody;
					
					[[UIApplication sharedApplication] cancelLocalNotification: notification];
					
					n2.fireDate = [localEvent.datetime dateByAddingTimeInterval:-[localEvent.startTracking doubleValue]];
					
					[[UIApplication sharedApplication] scheduleLocalNotification: n2];
				}
			}
		}
		
		
    }
    
    if([dictionary valueForKey:@"persons"]!= nil) {
        NSArray *serverPersonsUnsorted = [dictionary valueForKey:@"persons"];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES];
        
        NSArray *serverPersons = [serverPersonsUnsorted sortedArrayUsingDescriptors:@[descriptor]];
        
        NSArray *ids = [serverPersons valueForKey:@"userId"];
        
        NSArray *localPersonsUnsorted = [[localEvent persons] allObjects];
        
        NSSortDescriptor *descriptorLocal = [NSSortDescriptor sortDescriptorWithKey:@"entId" ascending:YES];
        NSPredicate *idfilter = [NSPredicate predicateWithFormat:@"entId in %@", ids];
        NSArray *localPersonsSorted = [localPersonsUnsorted filteredArrayUsingPredicate:idfilter];
        NSArray *localPersons = [localPersonsSorted sortedArrayUsingDescriptors:@[descriptorLocal]];
        
        int serverIterator = 0;
        int localIterator = 0;
        
       // NSInteger count = localPersons.count > serverPersons.count ? localPersons.count : serverPersons.count;
       // NSInteger checkIterator = 0;
        
        while (serverPersons.count > serverIterator) {
            NSDictionary *serverPersonDictionary = [serverPersons objectAtIndex:serverIterator];
            serverIterator++;
            Person *localPerson = nil;
            NSString *localId = nil;
            
            if(localPersons.count > 0 && localPersons.count > localIterator) {
                localPerson = [localPersons objectAtIndex:localIterator];
                localId = localPerson.entId;
            }
            
            
            if(serverPersonDictionary != nil) {
                NSString *serverID = [serverPersonDictionary objectForKey:@"userId"];
                
                if(localId != nil && [serverID isEqualToString:localId]) {
                    localIterator++;
                } else {

                    localPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
                    localPerson.entId = [serverPersonDictionary objectForKey:@"userId"];
                    [localPerson addEventsObject:localEvent];
                }
                
                [localPerson setName:[serverPersonDictionary objectForKey:@"name"]];
                [localPerson setPictureURL:[serverPersonDictionary objectForKey:@"photo"]];
                
                if([serverPersonDictionary objectForKey:@"location"]!=nil) {
                    NSDictionary *latLong = [serverPersonDictionary objectForKey:@"location"];
                    
                    if([latLong objectForKey:@"latitude"]!=nil)
                        localPerson.latitude = [latLong objectForKey:@"latitude"];
                    
                    
                    if([latLong objectForKey:@"longitude"]!=nil)
                        localPerson.longitude = [latLong objectForKey:@"longitude"];
                    
                    if([latLong objectForKey:@"heading"]!= nil)
                        localPerson.heading = [latLong objectForKey:@"heading"];
                    
                    
                }
            }
        }
    }
    
    if([dictionary valueForKey:@"messages"]!= nil) {
        NSArray *eventPeople = [[localEvent persons] allObjects];
		
		NSArray *messages = [dictionary valueForKey:@"messages"];
		
        for (NSDictionary *message in messages) {
            if([message objectForKey:@"message"] != nil && [message objectForKey:@"userId"]!=nil && [message objectForKey:@"statusTime"] != nil) {
                
                Person *messagePerson = nil;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"entId == %@", [message objectForKey:@"userId"]];
                NSArray *objects = [eventPeople filteredArrayUsingPredicate:predicate];
                if(objects != nil && objects.count>0) {
                    messagePerson = [objects objectAtIndex:0];
                } else {
                    continue;
                }
                
                Message *messageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
                [messageObject setMessage:[message objectForKey:@"message"]];
                [messageObject setDateTime:[NSDate dateWithTimeIntervalSince1970:[[message objectForKey:@"statusTime"] intValue]]];
                [messageObject setPerson:messagePerson];
                [messageObject setEvent:localEvent];
                [messageObject setSuccessful:[NSNumber numberWithBool:YES]];
                [messageObject setFailed:[NSNumber numberWithBool:NO]];
            }
            
        }
    }

}

#pragma mark - View Controllers

-(void)changeToList {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"primaryNavController"];
    [self.window setRootViewController:vc];
}

-(void)changeToIntro {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"introViewController"];
    [self.window setRootViewController:vc];
}

#pragma mark - Event Tracking

//TODO: All this event crap should be in the model
-(void)getEventsForTracking {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isFinished != YES && datetime >= %@ && hasJoined == YES && forcedNoTracking != YES", [[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *activeEvents = [NSMutableArray arrayWithCapacity:2];
    for(Event *event in results) {
        
        NSInteger time = [event.datetime timeIntervalSince1970] - [[NSDate new] timeIntervalSince1970];
        
        if([event.isNow boolValue] || time < [event.startTracking doubleValue]) {
            [activeEvents addObject:event];
        }
    }
    
    
    self.eventsTracking = [activeEvents copy];
    
    if(self.eventsTracking != nil && self.eventsTracking.count > 0) {

        self.trackingForEvent = YES;
        [self.locationTracker setIsHighAccuracy:YES];
       // [self.locationTracker startLocationTracking];
    } else {
        self.trackingForEvent = NO;
        //[self.locationTracker setIsHighAccuracy:NO];
    }
 
    [self getNextEventForTracking];
}


-(void)getNextEventForTracking {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isFinished != YES && hasJoined == YES && forcedNoTracking != YES && datetime >= %@", [NSDate new], [[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT]];
    [request setFetchLimit:1];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(result != nil && result.count>0) {
        Event *event = (Event *)[result objectAtIndex:0];
        NSDate *startTrackingDate = [[event datetime] dateByAddingTimeInterval:-[event.startTracking doubleValue]];
        if(![self.nextStartTrackingTime isEqualToDate:startTrackingDate]) {
            self.nextStartTrackingTime = startTrackingDate;
        }
    } else {
        self.nextStartTrackingTime = nil;
    }
    
    [self checkTimesAndUpdateLocationTracker];
}

-(BOOL)checkTimesAndUpdateLocationTracker {
    if(self.nextStartTrackingTime == nil && self.trackingForEvent == false) {
        [self.locationTracker stopLocationTracking];
        self.locationTracker.isHighAccuracy = FALSE;
        return false;
    }
    
    
    if([self.nextStartTrackingTime timeIntervalSince1970] < [[NSDate new] timeIntervalSince1970]+60  || self.trackingForEvent) {
        
        self.locationTracker.isHighAccuracy = TRUE;
		
        if(!self.locationTracker.isTracking)
            [self.locationTracker startLocationTracking];
        
        return true;
        
    } else {
        
        self.locationTracker.isHighAccuracy = FALSE;
        
        if(self.locationTracker== nil) {
            self.locationTracker = [[LocationTracker alloc] init];
        }
        if(!self.locationTracker.isTracking)
            [self.locationTracker startLocationTracking];
        
        return true;
        
    }
}

-(BOOL)shouldChangeToHighFrequency {
    if(self.nextStartTrackingTime < [[NSDate new] dateByAddingTimeInterval:60] || self.trackingForEvent) {
        
        return true;
        
    } else {
        return false;
    }
}

-(void)finishEvent:(Event *)event {
    [event setIsFinished:[NSNumber numberWithBool:YES]];
    [self saveContext];
    
    [self getEventsForTracking];
}

-(BOOL)isInProximityForEvent:(Event *)event :(CLLocation *)location {
    
    
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:[event.latitude doubleValue] longitude:[event.longitude doubleValue]];;
    CLLocationDistance distance = [location distanceFromLocation:eventLocation];
    
    float miles = distance/1609.344;
    if(miles < IS_IN_PROXIMITY_DISTANCE) {
        return true;
    } else {
        return false;
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MustardModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mustard.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{ NSPersistentStoreFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication } error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            return false;
        }
        return true;
    }
    return false;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Location Manager Update

- (void) finishedLocationUpdate:(CLLocationCoordinate2D)location :(double)heading {
    NSLog(@"%f, %f, %f", location.latitude, location.longitude, heading);
}

@end
