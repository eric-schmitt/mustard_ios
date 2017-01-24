//
//  SelectTrackingViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 5/4/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "SelectTrackingViewController.h"
#import "StartTrackingTableViewCell.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "CustomTimeViewController.h"
#import "NSDate+WT.h"
#import "UIView+Toast.h"

@interface SelectTrackingViewController ()

@end

@implementation SelectTrackingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    

    self.presetTime = [NSArray arrayWithObjects:NSLocalizedString(@"15 minutes before", nil), NSLocalizedString(@"30 minutes before", nil), NSLocalizedString(@"45 minutes before", nil), NSLocalizedString(@"1 hour before", nil), NSLocalizedString(@"Custom", nil), nil];
    
    self.trackingLabel.text = NSLocalizedString(@"Start tracking my location", nil);
    
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
	
	[self setTrackingValue:@"Join Flow - Select Tracking Time"];
	
	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
	}
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
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.presetTime.count-1) {
       // [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedCustom = YES;
    } else {
        self.selectedCustom = NO;
        int multiplier = 15 * 60;
        self.timeAmount = (indexPath.row +1) * multiplier;
    }
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
    if(self.selectedCustom) {
        [self performSegueWithIdentifier:@"selectTimeToCustomSegue" sender:self];
    } else {
		
		if(self.timeAmount == 0) {
			 [self performSegueWithIdentifier:@"selectTimeToCustomSegue" sender:self];
		}

        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if(self.isFromEvent) {
            [self.event setStartTracking:[NSNumber numberWithInt:self.timeAmount]];
            [delegate saveContext];
            
            [delegate getEventsForTracking];
			
			NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
			for (UILocalNotification *notification in notificationArray) {
				NSDictionary *userInfo = notification.userInfo;
				NSString *identifier = [userInfo valueForKey:@"eventId"];

				if([identifier isEqualToString:self.event.entId]) {
					
					UILocalNotification* n2 = [[UILocalNotification alloc] init];
					
					n2.userInfo = notification.userInfo;
					n2.alertTitle = notification.alertTitle;
					n2.alertBody = notification.alertBody;
					
					[[UIApplication sharedApplication] cancelLocalNotification: notification];

					n2.fireDate = [self.event.datetime dateByAddingTimeInterval:-self.timeAmount];
					[[UIApplication sharedApplication] scheduleLocalNotification: n2];
				}
			}
			
            [self.navigationController popViewControllerAnimated:YES];
            
            return;
        }
        
        
        Person *user = [delegate user];

        [self startLoadingScreen];
        
        [[API sharedAPI] sendJoinSeedWithUserId:user.entId withSeedID:self.event.entId completion:^(APIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self stopLoadingScreen];
                
                if(response.code == 200 || response.code == 204) {
                    NSError *peopleError = nil;
                    /*NSFetchRequest *allPeople = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
                    NSArray *people = [delegate.managedObjectContext executeFetchRequest:allPeople error:&peopleError];*/
                    
                    NSArray *people = [[self.event persons] allObjects];
                    NSArray *serverEvents = [response.responseDictionary objectForKey:@"seeds"];
                    
                    if(serverEvents.count == 0) return;
                    
                    NSDictionary *serverEvent = [serverEvents objectAtIndex:0];
                    
                    [delegate updateSingleEvent:self.event withServerDictionary:serverEvent withPeople:people];
                    [self.event setStartTracking:[NSNumber numberWithInt:self.timeAmount]];
                    [self.event setHasJoined:[NSNumber numberWithBool:YES]];
                    [self.event setIsFinished:[NSNumber numberWithBool:NO]];
                    
					UILocalNotification* n1 = [[UILocalNotification alloc] init];
					n1.fireDate = [self.event.datetime dateByAddingTimeInterval:-self.timeAmount];
					n1.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.event.entId, @"eventId", nil];
					n1.alertTitle = @"Started Tracking";
					n1.alertBody = [NSString stringWithFormat:@"Mustard has started tracking you for %@",self.event.title];
					[[UIApplication sharedApplication] scheduleLocalNotification: n1];
                    
                    [delegate saveContext];
                    
                    [delegate getEventsForTracking];
                    
                    [self performSegueWithIdentifier:@"selectTimeToListSegue" sender:self];
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
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"selectTimeToCustomSegue"]) {
        CustomTimeViewController *vc = (CustomTimeViewController *)segue.destinationViewController;
        vc.event = self.event;
        vc.isFromEvent = self.isFromEvent;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



@end
