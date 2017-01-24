//
//  ListViewController.m
//  Flock_ios
//
//  Created by Eric Schmitt on 4/7/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "ListViewController.h"
#import "MapViewController.h"
#import "Event.h"
#import "NSDate+WT.h"
#import "UIColor+HexString.h"
#import "JoinSeedViewController.h"


@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   /* IF LOCATION IS DISABLED:
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"]];
    
    */

    
    self.unjoinedCount.layer.cornerRadius = self.unjoinedCount.bounds.size.height/2.0f;
    [self setStatusBarBackgroundColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorFromHexString:@"#FDD447"];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateTables)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.eventList addSubview:self.refreshControl];
    
    self.pageTitle.text = NSLocalizedString(@"Seeds", nil);
	
	[self setTrackingValue:@"Seed List"];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self requestUpdateTables];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTables) name:EVENT_BROADCAST object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"(datetime >= %@ || isNow == YES) && hasJoined == YES", [[NSDate new] dateByAddingTimeInterval:-EVENT_HIDE]];
    
    NSError *error;
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if(result != nil) {
        self.events = result;
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.events = [self.events sortedArrayUsingDescriptors:descriptors];
    }
    

    
   
    
    if(self.events.count > 0) {
        self.noSeedsOverlay.hidden = YES;
    } else {
        self.noSeedsOverlay.hidden = NO;
    }
    
    NSFetchRequest * request2 = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request2.predicate = [NSPredicate predicateWithFormat:@"isFinished == NO && datetime >= %@ && hasJoined == NO", [[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT]];
    
    NSError *error2;
    NSArray *joinedResult = [delegate.managedObjectContext executeFetchRequest:request2 error:&error2];
    
    
    if(joinedResult != nil && joinedResult.count> 0) {
        self.unjoinedSeedsButton.hidden = NO;
        self.unjoinedCount.hidden = NO;
        if(joinedResult.count > 99) {
            self.unjoinedCountLabel.text = @"99";
        } else {
            self.unjoinedCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)joinedResult.count];
        }
        
    } else {
        self.unjoinedSeedsButton.hidden = YES;
        self.unjoinedCount.hidden = YES;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_BROADCAST object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTables {
    [self.eventList reloadData];
    [self.refreshControl endRefreshing];
}

-(void)requestUpdateTables {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateLists];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    if (!cell) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"eventCell"];
    }
    
    Event *event = [self.events objectAtIndex:indexPath.row];
    
    cell.title.text = event.title;
    
    NSString *dateString;
    
    if([event.datetime isToday]) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        dateString = [NSString stringWithFormat:NSLocalizedString(@"Today @ %@", nil), timeString];
    } else if([event.datetime isTomorrow]) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        dateString = [NSString stringWithFormat:NSLocalizedString(@"Tomorrow @ %@", nil), timeString];
    } else {
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *dateComponents = @"EEEEMMMMd h:mm a";
        
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocale];
        
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        
        dateString = [dateFormatter stringFromDate:event.datetime];
    }

    cell.when.text = dateString;
    cell.event = event;

    return cell;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             Event *event = [self.events objectAtIndex:indexPath.row];
                                             NSMutableArray *mutableEvents = [self.events mutableCopy];
                                             [mutableEvents removeObject:event];
                                             self.events = [mutableEvents copy];
                                             
                                             [self.eventList beginUpdates];
                                             [self.eventList deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationTop];
                                             [self.eventList endUpdates];

											 NSArray *notificationArray = [[UIApplication sharedApplication]     scheduledLocalNotifications];

											 for ( UILocalNotification *notification in notificationArray) {
												 NSDictionary *userInfo = notification.userInfo;
												 NSString *identifier = [userInfo valueForKey:@"eventId"];
												 if([identifier isEqualToString:event.entId]) {
													 [[UIApplication sharedApplication] cancelLocalNotification:notification];
												 }
											 }
                                             
                                             AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                             [delegate.managedObjectContext deleteObject:event];
                                             [delegate saveContext];
                                         });
                                     }];
    button.backgroundColor = [UIColor redColor];
    
    return @[button];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"mapSegue"])
    {
        // Get reference to the destination view controller
        MapViewController *vc = [segue destinationViewController];

        Event *event = self.selectedEventCell.event;
        vc.event = event;
        vc.people = [[event persons] allObjects];

    } else if ([[segue identifier] isEqualToString:@"JoinSeed"])
    {
        JoinSeedViewController *seedVC = [segue destinationViewController];
        seedVC.event = [self.events objectAtIndex:0];
    }
}
- (IBAction)joinShort:(id)sender {
    [self performSegueWithIdentifier:@"JoinSeed" sender:self];
}

- (void)setStatusBarBackgroundColor{
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor colorFromHexString:@"#B09025"];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    dispatch_async(dispatch_get_main_queue(), ^{

        self.selectedEventCell = [self.eventList cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"mapSegue" sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
