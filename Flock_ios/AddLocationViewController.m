//
//  AddLocationViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddLocationViewController.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "AddSeedData.h"
#import "AddLocationNameViewController.h"

@interface AddLocationViewController ()

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    

	self.inputAccessoryView.translatesAutoresizingMaskIntoConstraints = true;
    
    self.hasTrackedToUser = NO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.map addGestureRecognizer:lpgr];
    
    self.deleteLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.deleteLabel.layer.borderWidth = 2.0f;
    self.deleteLabel.layer.cornerRadius = self.deleteLabel.bounds.size.height/2.0f;
    
    UITapGestureRecognizer *removeAnnotations = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAnnotations:)];
    removeAnnotations.numberOfTouchesRequired = 1;
    [self.removeAnnotationView addGestureRecognizer:removeAnnotations];
    self.removeAnnotationView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    hideKeyboard.numberOfTouchesRequired = 1;
    [self.map addGestureRecognizer:hideKeyboard];

    
    self.tapHereText.text = NSLocalizedString(@"Tap here to remove the pin...", nil);
    [self.searchButton setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];
    self.searchText.placeholder = NSLocalizedString(@"Search or tap and hold the map...", nil);
    
    [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
	
	[self setTrackingValue:@"Create Flow - Add Location"];

}

-(void)viewWillAppear:(BOOL)animated {
	
    if(self.isFromEvent) {
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        
        CLLocation *coord = [[CLLocation alloc] initWithLatitude:[self.event.latitude floatValue] longitude:[self.event.longitude floatValue]];
        annot.coordinate = coord.coordinate;
        if(self.event.locationName != nil) {
            annot.title = self.event.locationName;
        } else {
            annot.title = @"Dropped Pin";
        }
        
        self.selectedLocation = annot;
        
        [self.map addAnnotation:annot];
    } else {
        if([[AddSeedData seedData] eventLocation] != nil) {
            MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
            annot.coordinate = [[AddSeedData seedData] eventLocation].coordinate;
            if([[AddSeedData seedData] locationName] != nil) {
                annot.title = [[AddSeedData seedData] locationName];
            } else {
                annot.title = @"Dropped Pin";
            }
            [self.map addAnnotation:annot];
        }
    }
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[self checkForPermissionAndStartUpdating];
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if(!self.hasTrackedToUser) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.01;
        span.longitudeDelta = 0.01;
        CLLocationCoordinate2D location;
        location.latitude = userLocation.coordinate.latitude;
        location.longitude = userLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [mapView setRegion:region animated:NO];
        self.hasTrackedToUser = YES;
    }
}


#pragma mark - Location
-(BOOL)checkForPermission {
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
        return false;
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return true;
    } else {
        return false;
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusDenied) {
		// permission denied
		[self.map setShowsUserLocation:NO];
	}
	else if (status == kCLAuthorizationStatusAuthorized) {
		// permission granted
		[self.map setShowsUserLocation:YES];
	}
}

- (IBAction)nextLocationPressed:(id)sender {
    if(self.selectedLocation != nil) {
        [self.locationManager stopUpdatingLocation];
        
        if(self.isFromEvent) {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [delegate managedObjectContext];
            [self.event setLongitude:[NSNumber numberWithDouble:self.selectedLocation.coordinate.longitude]];
            [self.event setLatitude:[NSNumber numberWithDouble:self.selectedLocation.coordinate.latitude]];
			
            NSError *saveError;
            if([context save:&saveError]) {
                NSLog(@"%@", saveError.localizedDescription);
            }
			[context refreshObject:self.event mergeChanges:YES];
            
        } else {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:self.selectedLocation.coordinate.latitude longitude:self.selectedLocation.coordinate.longitude];
            [[AddSeedData seedData] setEventLocation:location];
            
        }
        [self performSegueWithIdentifier:@"locationNameSegue" sender:nil];
        
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageAlignment = NSTextAlignmentCenter;
        [self.view makeToast:NSLocalizedString(@"Select a location.", nil)
                    duration:1.5
                    position:CSToastPositionTop
                       style:style];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(self.isFromEvent && [[segue identifier] isEqualToString:@"locationNameSegue"]) {
        AddLocationNameViewController *vc = (AddLocationNameViewController *)[segue destinationViewController];
        vc.event = self.event;
        vc.isFromEvent = YES;
    }
}

- (IBAction)searchButtonPressed:(id)sender {
    if(self.searchText.text.length > 0) {
        
        
        MKLocalSearchRequest *request =
        [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = self.searchText.text;
        request.region = self.map.region;
        
        NSMutableArray *matchingItems = [[NSMutableArray alloc] init];
        
        MKLocalSearch *search =
        [[MKLocalSearch alloc]initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse
                                             *response, NSError *error) {
            if (response.mapItems.count == 0) {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageAlignment = NSTextAlignmentCenter;
                [self.view makeToast:NSLocalizedString(@"No matches.", nil)
                            duration:1.5
                            position:CSToastPositionTop
                               style:style];
            } else
                for (MKMapItem *item in response.mapItems)
                {
                    [matchingItems addObject:item];
                    MKPointAnnotation *annotation =
                    [[MKPointAnnotation alloc]init];
                    annotation.coordinate = item.placemark.coordinate;
                    annotation.title = item.name;
                    [self.map addAnnotation:annotation];
                }
        }];
        [self.searchText resignFirstResponder];
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageAlignment = NSTextAlignmentCenter;
        [self.view makeToast:NSLocalizedString(@"Enter a search term.", nil)
                    duration:1.5
                    position:CSToastPositionTop
                       style:style];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startUpdatingLocation {
    if([self checkForPermission]) {
        self.awaitingAuthForTracking = false;
        [self.locationManager startUpdatingLocation];
        //self.map.showsUserLocation = true;
        
    }
}

-(void)checkForPermissionAndStartUpdating {
    self.awaitingAuthForTracking = true;
    [self startUpdatingLocation];
    
}


#pragma mark - Interactions

-(void)removeAnnotations:(UIGestureRecognizer *)gestureRecognizer {
    
    NSMutableArray * annotationsToRemove = [self.map.annotations mutableCopy] ;
    [annotationsToRemove removeObject:self.map.userLocation] ;
    [self.map removeAnnotations:annotationsToRemove] ;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.removeAnnotationView.hidden = true;
        self.removeAnnotationView.alpha = 0.0f;
    }];
    self.selectedLocation = nil;
    [[AddSeedData seedData] setLocationName:nil];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    [self removeAnnotations:nil];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.title = @"Dropped Pin";
    [self.map addAnnotation:annot];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.removeAnnotationView.hidden = false;
        self.removeAnnotationView.alpha = 1.0f;
    }];
    
    self.selectedLocation = annot;
    
}

-(void)hideKeyboard:(id)sender {
    [self.searchbox resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(self.searchText.text.length > 0)
        [self searchButtonPressed:nil];
    [textField resignFirstResponder];
    return YES;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if(annotation != self.map.userLocation) {
        MKAnnotationView *annView =[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
        annView.image = [UIImage imageNamed:@"icon_small"];

        annView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        
        annView.draggable = YES;
        annView.canShowCallout = YES;
      
        return annView;
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.selectedLocation = view.annotation;
    [[AddSeedData seedData] setLocationName:view.annotation.title];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
