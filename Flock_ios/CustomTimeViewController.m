//
//  CustomTimeViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/18/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "CustomTimeViewController.h"
#import "AppDelegate.h"
#import "NSDate+WT.h"
#import "UIView+Toast.h"
#import "MapViewController.h"

@interface CustomTimeViewController ()

@end

@implementation CustomTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.event.title;
    self.locationLabel.text = self.event.locationName;
    


    self.datePicker.countDownDuration = 1800;
    
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
    
    self.timeTable.text = dateString;
    
    self.detailLabel.text = NSLocalizedString(@"How long before to start?", nil);
    
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.backButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];

    [self setTrackingValue:@"Join Flow - Custom Tracking Time"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)nextButtonPressed:(id)sender {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if(self.isFromEvent) {
        [self.event setStartTracking:[NSNumber numberWithDouble:self.datePicker.countDownDuration]];
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
				
				n2.fireDate = [self.event.datetime dateByAddingTimeInterval:-self.datePicker.countDownDuration];
				[[UIApplication sharedApplication] scheduleLocalNotification: n2];
			}
		}
		
        UIViewController *mapVC = nil;
        
        for(UIViewController *vc in self.navigationController.viewControllers) {
            if([vc isKindOfClass:[MapViewController class]]) {
                mapVC = vc;
            }
        }
        
        if(mapVC != nil) {
            [self.navigationController popToViewController:mapVC animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return;
    }
    
    
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
                [self.event setStartTracking:[NSNumber numberWithDouble:self.datePicker.countDownDuration]];
                [self.event setHasJoined:[NSNumber numberWithBool:YES]];
				
				UILocalNotification* n1 = [[UILocalNotification alloc] init];
				n1.fireDate = [self.event.datetime dateByAddingTimeInterval:-self.datePicker.countDownDuration];
				n1.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.event.entId, @"eventId", nil];
				n1.alertTitle = @"Started Tracking";
				n1.alertBody = [NSString stringWithFormat:@"Mustard has started tracking you for %@",self.event.title];
				[[UIApplication sharedApplication] scheduleLocalNotification: n1];
				
                [delegate saveContext];
                
                [delegate getEventsForTracking];
                
                [self performSegueWithIdentifier:@"customToListSegue" sender:self];
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

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)datePickedValueChanged:(id)sender {
    
}

@end
