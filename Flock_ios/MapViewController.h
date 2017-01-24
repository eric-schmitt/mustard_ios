//
//  MapViewController.h
//  Flock_ios
//
//  Created by Eric Schmitt on 4/8/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "Person.h"
#import "Message.h"
#import "MustardViewController.h"

@interface MapViewController : MustardViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSArray *people;
@property (strong, nonatomic) NSMutableArray *peopleAppendedToEvent;
@property (strong, nonatomic) NSMutableArray *peopleNotTracking;
@property (strong, nonatomic) NSMutableArray *imageAnnotationsOnEvent;
@property (strong, nonatomic) NSMutableArray *orderedPeopleForEvent;
@property BOOL limitingPeople;
@property (strong, nonatomic) UILabel *locationName;
@property CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *arrivedLabel;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *noLongerAvialableText;

@property (weak, nonatomic) MKPointAnnotation *eventAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *noStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *lastStatusDisplay;
@property (weak, nonatomic) IBOutlet UIImageView *lastStatusProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *lastStatusName;
@property (weak, nonatomic) IBOutlet UILabel *lastStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *peopleView;
@property (weak, nonatomic) IBOutlet UIView *toolsOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *peopleViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property float trailingConstraintConstant;
@property BOOL isSideBarOpen;
@property BOOL isOptionsOpen;
@property BOOL peopleAtSeedOpen;
@property int currentOffset;
@property int totalUsers;

@property (strong, nonatomic) NSMutableDictionary *peopleToAnnotations;
@property (weak, nonatomic) IBOutlet UITableView *peopleTable;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIImageView *detailViewProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *detailViewnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailViewDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailViewLastStatus;
@property (weak, nonatomic) IBOutlet UIButton *startTrackingButton;
@property (weak, nonatomic) IBOutlet UIButton *changeTrackingButton;
@property (weak, nonatomic) IBOutlet UIButton *changeLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *changeTimeBUtton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) NSTimer *updateTimer;

@property (weak, nonatomic) IBOutlet UIButton *nextSetButton;
@property (weak, nonatomic) IBOutlet UIButton *previousSetButton;
@property (weak, nonatomic) IBOutlet UILabel *offSetLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIView *counterWarp;


- (IBAction)backPressed:(id)sender;
- (IBAction)recenterPressed:(id)sender;
- (IBAction)expandSideBarPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)configPressed:(id)sender;
- (IBAction)nextOffsetPressed:(id)sender;
- (IBAction)prevOffsetPressed:(id)sender;


-(NSString *)getDistanceTextFromDistance:(double) distance;
-(void)toggleSideBar;
-(void)showPersonDetail:(Person *) person;
-(void)hideDetail;
- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
- (BOOL)isMetric;
- (IBAction)startTrackingNow:(id)sender;


@end
