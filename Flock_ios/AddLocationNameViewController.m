//
//  AddLocationNameViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/14/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddLocationNameViewController.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "AddSeedData.h"
#import "AddPeopleViewController.h"
#import "UIColor+HexString.h"
#import "MapViewController.h"

@interface AddLocationNameViewController ()

@end

@implementation AddLocationNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.inputAccessoryView.translatesAutoresizingMaskIntoConstraints = true;
	
    [self.controls removeFromSuperview];
    
    if(self.isFromEvent) {
        self.nameTextBox.text = self.event.locationName;
        
    } else if([[AddSeedData seedData] locationName] != nil) {
        self.nameTextBox.text = [[AddSeedData seedData] locationName];
    }
    
    self.nameTextBox.layer.cornerRadius = 3.0f;
    self.nameTextBox.layer.borderColor = [UIColor colorFromHexString:@"FDD447"].CGColor;
    
    [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    
    self.titleLabel.text = NSLocalizedString(@"Give this place a name", nil);
	
	[self setTrackingValue:@"Create Flow - Add Location Name"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButton:(id)sender {
    
    if(self.nameTextBox.text.length > 0) {

        if(self.isFromEvent) {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [delegate managedObjectContext];
            
            [self.event setLocationName:self.nameTextBox.text];
            
            NSError *saveError;
            if([context save:&saveError]) {
                NSLog(@"%@", saveError.localizedDescription);
            }
            
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
						
						/*
                        if(response.responseDictionary.count == 0 || [response.responseDictionary objectForKey:idKey] == nil || [response.responseDictionary objectForKey:urlKey] == nil) {
                            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                            style.messageAlignment = NSTextAlignmentCenter;
                            [self.view makeToast:NSLocalizedString(@"Could not connect.", nil)
                                        duration:1.5
                                        position:CSToastPositionTop
                                           style:style];
                            return;
                        }*/
						
						id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
						
						if([self.event.isNow boolValue]) {
							[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Create Seed"
																				  action:@"Now Event"
																				   label:nil
																				   value:nil] build]];
						} else {
							[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Create Seed"
																				  action:@"Scheduled Event"
																				   label:nil
																				   value:nil] build]];
						}
                        
                        
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            if([controller isKindOfClass:[MapViewController class]]) {
                                [self.navigationController popToViewController:controller animated:YES];
                                return;
                            }
                        }
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
            [self.nameTextBox resignFirstResponder];
            [self startLoadingScreen];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *userID = [delegate user].entId;
            
            NSNumber *isNow = [NSNumber numberWithInt:0];
            if([[[AddSeedData seedData] isNow] boolValue])
                isNow = [NSNumber numberWithInt:1];

            [[API sharedAPI] sendCreateSeed:[[AddSeedData seedData] date] latitude:[NSNumber numberWithDouble:[[[AddSeedData seedData] eventLocation] coordinate].latitude] longitude:[NSNumber numberWithDouble:[[[AddSeedData seedData] eventLocation] coordinate].longitude] personId:userID title:[[AddSeedData seedData] seedName] locationName:self.nameTextBox.text isNow:isNow completion:^(APIResponse *response) {
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
                        
                       
                        
                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        NSManagedObjectContext *context = [delegate managedObjectContext];
                        
                        NSString *entId = [response.responseDictionary objectForKey:idKey];
                        NSString *linkURL = [response.responseDictionary objectForKey:urlKey];
                        
                        self.event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
                        [self.event setEntId:entId];
                        [self.event setLink:linkURL];
                        [self.event setTitle:[[AddSeedData seedData] seedName]];
                        [self.event setDatetime:[[AddSeedData seedData] date]];
                        
                        
                        
                        if([[[AddSeedData seedData] isNow] intValue] == 1)
                            [self.event setIsNow:[NSNumber numberWithBool:YES]];
                        else
                            [self.event setIsNow:[NSNumber numberWithBool:NO]];
                        
                        [self.event setLongitude:[NSNumber numberWithDouble:[[[AddSeedData seedData] eventLocation] coordinate].longitude]];
                        [self.event setLatitude:[NSNumber numberWithDouble:[[[AddSeedData seedData] eventLocation] coordinate].latitude]];
                        [self.event setIsOwner:[NSNumber numberWithBool:YES]];
                        [self.event setIsFinished:[NSNumber numberWithBool:NO]];
                        [self.event setLocationName:self.nameTextBox.text];
                        
                        [delegate saveContext];
                        [delegate getEventsForTracking];
                        
                        [[AddSeedData seedData] clearData];
                        
                        [self performSegueWithIdentifier:@"addPeopleSegue" sender:self];
                        
                    } else if(response.code == INTERNAL_ERROR) {
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
        
        
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageAlignment = NSTextAlignmentCenter;
        [self.view makeToast:NSLocalizedString(@"Enter a location name.", nil)
                    duration:1.5
                    position:CSToastPositionTop
                       style:style];
    }
}

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"addPeopleSegue"])
    {
        AddPeopleViewController *vc = [segue destinationViewController];
        vc.event = self.event;
        vc.link = self.event.link;
    }
}

- (UIView *)inputAccessoryView{
    
    return self.controls;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
