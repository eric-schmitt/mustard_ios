//
//  JoinSeedViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/18/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "JoinSeedViewController.h"
#import "StartTrackingTableViewCell.h"
#import "ListViewController.h"
#import "MapViewController.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "UnjoinedSeedsViewController.h"
#import "SelectTrackingViewController.h"
#import "NSDate+WT.h"
#import <MapKit/MapKit.h>
#import "UIView+Toast.h"

@interface JoinSeedViewController ()

@end

@implementation JoinSeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *controllersToKeep = [NSMutableArray arrayWithCapacity:1];
    for(UIViewController *controller in self.navigationController.childViewControllers) {
        if([controller isKindOfClass:[ListViewController class]] || [controller isKindOfClass:[MapViewController class]] || [controller isKindOfClass:[UnjoinedSeedsViewController class] ]) {
            [controllersToKeep addObject:controller];
        }
        
    }
    
    [controllersToKeep addObject:self];
    
    [self.navigationController setViewControllers:[controllersToKeep copy]];
    
    
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.backButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];

	[self setTrackingValue:@"Join Flow - View Seed"];
    
    self.gettingSeedLabel.text = NSLocalizedString(@"Getting your seed!", nil);
    self.gettingSeedDetail.text = NSLocalizedString(@"This will just take a moment...", nil);
    if(self.needsRequest) {
        self.loadingView.layer.cornerRadius = 3.0f;
        self.loadingViewOverlay.hidden = NO;
        self.loadingView.hidden = NO;
        [[API sharedAPI] sendGetSeedData:self.eventStringID completion:^(APIResponse *response) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(response.code == 200 || response.code == 204) {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    self.loadingViewOverlay.hidden = YES;
                    
                    if([response.responseDictionary objectForKey:@"items"]) {
                        
                        NSArray *items = [response.responseDictionary objectForKey:@"items"];
                        
                        if(items.count == 0) [self.navigationController popViewControllerAnimated:YES];
                        
                        NSDictionary *eventResponse = [items objectAtIndex:0];
                        
                        if(eventResponse != nil) {
                            NSString *entId = [eventResponse objectForKey:@"id"];
                            
                            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"entId == %@", entId];
                            [request setPredicate:predicate];
                            NSError *error = nil;
                            NSArray *events = [delegate.managedObjectContext executeFetchRequest:request error:&error];
                            
                            if(events.count > 0) {
                                
                                self.event = [events objectAtIndex:0];
                                
                            } else {
                                self.event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:delegate.managedObjectContext];
                                if([eventResponse objectForKey:@"id"] != nil) {
                                    self.event.entId = [eventResponse objectForKey:@"id"];
                                }
                            }
                            
                            
                            
                            if([eventResponse objectForKey:@"title"] != nil) {
                                self.event.title = [eventResponse objectForKey:@"title"];
                            }
                            if([eventResponse objectForKey:@"locationName"] != nil) {
                                self.event.locationName = [eventResponse objectForKey:@"locationName"];
                            }
                            if([eventResponse objectForKey:@"location"] != nil) {
                                NSDictionary *latLong = [eventResponse objectForKey:@"location"];
                                
                                if([latLong objectForKey:@"latitude"] != nil) {
                                    self.event.latitude = [latLong objectForKey:@"latitude"];
                                }
                                if([latLong objectForKey:@"longitude"] != nil) {
                                    self.event.longitude = [latLong objectForKey:@"longitude"];
                                }
                            }
                            if([eventResponse objectForKey:@"isNow"] != nil) {
                                NSNumber *isNow = [eventResponse objectForKey:@"isNow"];
                                if([isNow intValue] == 1) self.event.isNow = [NSNumber numberWithBool:YES];
                                else self.event.isNow = [NSNumber numberWithBool:NO];
                            }
                            
                            if([eventResponse objectForKey:@"datetime"] != nil) {
								NSLog(@"%f", [[eventResponse objectForKey:@"datetime"] doubleValue]);
                                 self.event.datetime = [NSDate dateWithTimeIntervalSince1970:[[eventResponse objectForKey:@"datetime"] doubleValue]];
                            }

                            [delegate saveContext];
                            
                            [self prepEvent];
                            
                        } else {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        }];
     } else {
        [self prepEvent];
         self.loadingViewOverlay.hidden = YES;
        
    }
	
	
	
	
}

-(void)prepEvent {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
    if([self.event.isNow boolValue]) {
		
		
        self.trackingLabel.text = NSLocalizedString(@"This seed will start tracking now.", nil);
		
		[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Seed"
															  action:@"Now Event"
															   label:@"play"
															   value:nil] build]];
    } else {
        self.trackingLabel.text = NSLocalizedString(@"You can select when to start tracking.", nil);
		
		[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Seed"
															  action:@"Scheduled Event"
															   label:@"play"
															   value:nil] build]];
        
        self.trackingLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextButtonPressed:)];
        [self.trackingLabel addGestureRecognizer:tap];
    }
    
    if(self.event != nil) {
        self.titleLabel.text = self.event.title;
        self.locationLabel.text = self.event.locationName;
        
        NSString *dateString;
        
        if([self.event.datetime isToday]) {
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setTimeStyle:NSDateFormatterShortStyle];
            NSString *timeString = [NSDateFormatter localizedStringFromDate:self.event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            
            dateString = [NSString stringWithFormat:NSLocalizedString(@"Today @ %@", nil), timeString];
        } else if([self.event.datetime isTomorrow]) {
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setTimeStyle:NSDateFormatterShortStyle];
            NSString *timeString = [NSDateFormatter localizedStringFromDate:self.event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            
            dateString = [NSString stringWithFormat:NSLocalizedString(@"Tomorrow @ %@", nil), timeString];
        } else {
            NSLocale *currentLocale = [NSLocale currentLocale];
            NSString *dateComponents = @"EEEEMMMMd h:mm a";
            
            NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocale];
            
            NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateFormat];
            
            dateString = [dateFormatter stringFromDate:self.event.datetime];
        }
        
        self.timeLabel.text = dateString;
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D eventLocation;
        eventLocation.latitude = [self.event.latitude doubleValue];
        eventLocation.longitude = [self.event.longitude doubleValue];
        point.coordinate = eventLocation;
        [self.map addAnnotation:point];
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(point.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 20, 20);
        MKCoordinateRegion region = MKCoordinateRegionMake(point.coordinate, MKCoordinateSpanMake(0.005, 0.005));
        [self.map setRegion:region];
    }
        //[self.map setCenterCoordinate:eventLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presetTime.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *time = [self.presetTime objectAtIndex:indexPath.row];
    
    
    
    StartTrackingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackingCell"];
    
    
    cell.timeLabel.text = time;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorFromHexString:@"#FFF9DA"];
    [cell setSelectedBackgroundView:bgColorView];
 
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.backButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.presetTime.count-1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        int multiplier = 15 * 60;
        self.timeAmount = (indexPath.row +1) * multiplier;
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    MKAnnotationView *annView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    annView.image = [UIImage imageNamed:@"icon_small"];
    annView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    return annView;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonPressed:(id)sender {
    if([self.event.isNow boolValue]) {

        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Person *user = [delegate user];
        
        [self startLoadingScreen];
        
        [[API sharedAPI] sendJoinSeedWithUserId:user.entId withSeedID:self.event.entId completion:^(APIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self stopLoadingScreen];
                
                if(response.code == 200 || response.code == 204) {
                    NSError *peopleError = nil;
                    NSFetchRequest *allPeople = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
                    NSArray *people = [delegate.managedObjectContext executeFetchRequest:allPeople error:&peopleError];
                    
                    NSDictionary *serverEvent = response.responseDictionary;
                    [delegate updateSingleEvent:self.event withServerDictionary:serverEvent withPeople:people];
                    [self.event setHasJoined:[NSNumber numberWithBool:YES]];
					
                    [delegate saveContext];
                    
                    [delegate getEventsForTracking];
                    
                    [self performSegueWithIdentifier:@"joinToListSegue" sender:self];
                } else {
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageAlignment = NSTextAlignmentCenter;
                    [self.view makeToast:NSLocalizedString(@"Could not connect.", nil)
                                duration:1.5
                                position:CSToastPositionTop
                                   style:style];
                    return;
                }
            });
        }];
        
    } else {
        [self performSegueWithIdentifier:@"joinToSelectTimeSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"joinToSelectTimeSegue"]) {
        SelectTrackingViewController *vc = (SelectTrackingViewController *)segue.destinationViewController;
        vc.event = self.event;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeButtonPressed:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate changeToList];
}
@end
