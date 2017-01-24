//
//  AddTimeViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddTimeViewController.h"
#import "AddLocationViewController.h"
#import "AddSeedData.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "MapViewController.h"

@interface AddTimeViewController ()

@end

@implementation AddTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.inputAccessoryView.translatesAutoresizingMaskIntoConstraints = true;
	
    [self.cancelButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];

    
    [self.datePicker setValue:[UIColor colorFromHexString:@"#5C5C5C"] forKeyPath:@"textColor"];
    [self.datePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    
    
    self.datePicker.minimumDate = [NSDate date];
    
    if(self.isFromEvent) {
        self.startNowButton.hidden = YES;
        self.orImage.hidden = YES;
        self.datePicker.date = self.event.datetime;
    }
    else if([[AddSeedData seedData] date] != nil) {
        self.datePicker.date = [[AddSeedData seedData] date];
    } else {
        self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:(3600*2)];
    }
    
    self.titleLabel.text = NSLocalizedString(@"Give a time", nil);

     [self.startNowButton setTitle:NSLocalizedString(@"Start this seed now!", nil) forState:UIControlStateNormal];
    
    [self setTrackingValue:@"Create Flow - Add Time"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonPressed:(id)sender {
    if(self.isFromEvent) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        [self.event setDatetime:self.datePicker.date];
        [self.event setIsNow:[NSNumber numberWithBool:NO]];
        NSError *saveError;
        if([context save:&saveError]) {
            NSLog(@"%@", saveError.localizedDescription);
        }
        
        [self sendAndReturnToMap];

    } else {
        [[AddSeedData seedData] setDate:self.datePicker.date];
        [self performSegueWithIdentifier:@"locationSegue" sender:self];
    }
}

-(void)sendAndReturnToMap {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber *isNow = [NSNumber numberWithInt:0];
    if([self.event.isNow boolValue])
        isNow = [NSNumber numberWithInt:1];
    
    [self startLoadingScreen];
    
    [[API sharedAPI] sendUpdateSeed:self.event.entId datetime:self.event.datetime latitude:self.event.latitude longitude:self.event.longitude personId:[delegate user].entId title:self.event.title locationName:self.event.locationName isNow:isNow completion:^(APIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self stopLoadingScreen];
            
            if(response.code == 200 || response.code == 204) {
                
                NSString *idKey = @"id";
                NSString *urlKey = @"url";
                
                if(response.responseDictionary.count == 0 || [response.responseDictionary objectForKey:idKey] == nil || [response.responseDictionary objectForKey:urlKey] == nil) {
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageAlignment = NSTextAlignmentCenter;
                    [self.view makeToast:NSLocalizedString(@"Could not connect.", nil)
                                duration:1.5
                                position:CSToastPositionTop
                                   style:style];
                    return;
                }
				
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
						
						n2.fireDate = [self.event.datetime dateByAddingTimeInterval:-[self.event.startTracking doubleValue]];
						[[UIApplication sharedApplication] scheduleLocalNotification: n2];
					}
				}
				
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if([controller isKindOfClass:[MapViewController class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                        return;
                    }
                }
                
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [delegate getEventsForTracking];
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (IBAction)startNowPressed:(id)sender {
    if(self.isFromEvent) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        [self.event setDatetime:self.datePicker.date];
        [self.event setIsNow:[NSNumber numberWithBool:YES]];
        NSError *saveError;
        if([context save:&saveError]) {
            NSLog(@"%@", saveError.localizedDescription);
        }
        
        [self sendAndReturnToMap];
        
    } else {
        [[AddSeedData seedData] setDate:[NSDate new]];
        [[AddSeedData seedData] setIsNow:[NSNumber numberWithInt:1]];

        [self performSegueWithIdentifier:@"locationSegue" sender:self];
    }
}

@end
