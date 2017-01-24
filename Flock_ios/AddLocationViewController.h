//
//  AddLocationViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "MustardViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AddLocationViewController : MustardViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *textboxContainer;
@property (weak, nonatomic) IBOutlet UIView *searchbox;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *tapHereText;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIView *removeAnnotationView;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (strong, nonatomic) MKPointAnnotation *selectedLocation;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property Event *event;

@property BOOL awaitingAuthForTracking;
@property BOOL hasTrackedToUser;
@property BOOL isFromEvent;

-(void)checkForPermissionAndStartUpdating;
-(void)startUpdatingLocation;
-(BOOL)checkForPermission;
- (IBAction)nextLocationPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;



@end
