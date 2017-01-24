//
//  JoinSeedViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/18/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MustardViewController.h"

@interface JoinSeedViewController : MustardViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSArray *presetTime;
@property float timeAmount;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *loadingViewOverlay;
@property BOOL needsLoading;
@property NSString *linkToLoad;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UILabel *gettingSeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *gettingSeedDetail;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *trackingLabel;
@property (weak, nonatomic) IBOutlet MKMapView *map;


@property NSDictionary *eventDictionary;
@property Event *event;
@property NSString *eventStringID;
@property BOOL needsRequest;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end
