//
//  MapViewController.m
//  Flock_ios
//
//  Created by Eric Schmitt on 4/8/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#define DEGREES_TO_RADIANS(angle) (angle) / 180.0 * M_PI

#import "MapViewController.h"
#import "StatusViewController.h"
#import "PeopleTableViewCell.h"
#import "AppDelegate.h"
#import "UIColor+HexString.h"
#import "MapPinAnnotation.h"
#import "PersonPointAnnotation.h"
#import "AddPeopleViewController.h"
#import "UIColor+HexString.h"
#import "AddLocationViewController.h"
#import "AddTimeViewController.h"
#import "SelectTrackingViewController.h"
#import "UIImageView+Haneke.h"
#import "UIColor+HexString.h"
#import "UIImage+ProperRotation.h"
#define MAP_LIMIT 30

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peopleLabel.text = NSLocalizedString(@"People", nil);
    
    self.peopleView.layer.borderWidth = 1.0f;
    self.peopleView.layer.borderColor = [UIColor colorFromHexString:@"#AAAAAA"].CGColor;
    ;
	
	self.counterWarp.layer.borderWidth = 1.0f;
	self.counterWarp.layer.borderColor  = [UIColor colorFromHexString:@"#FDD447"].CGColor;
	self.counterWarp.layer.cornerRadius = self.counterWarp.frame.size.height/2.0f;

	self.map.delegate = self;
    
    self.isOptionsOpen = NO;
    self.toolsOverlay.hidden = YES;
	//BOOL limitingPeople = NO;
    self.toolsOverlay.layer.cornerRadius = 3.0f;
    
    self.eventTitle.text = self.event.title;
    
    self.map.showsUserLocation = true;
	
	self.noLongerAvialableText.layer.cornerRadius = 11;
	self.noLongerAvialableText.layer.borderColor = [UIColor blackColor].CGColor;
	self.noLongerAvialableText.layer.borderWidth = 1;
	if(![self.event.isFinished boolValue]) {
		self.noLongerAvialableText.hidden = true;
	} else {
		self.noLongerAvialableText.hidden = false;
	}
    
    if(![self.event.isOwner boolValue]) {
        self.changeLocationButton.hidden = YES;
        self.changeTimeBUtton.hidden = YES;
    }
    if([self.event.isNow boolValue]) {
        self.changeTimeBUtton.hidden = YES;
    }
    
    UITapGestureRecognizer *openMessages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMessages:)];
    openMessages.numberOfTouchesRequired = 1;
    [self.statusView addGestureRecognizer:openMessages];
    self.statusView.userInteractionEnabled = YES;

    self.lastStatusProfilePicture.layer.cornerRadius = 21;
    self.lastStatusProfilePicture.clipsToBounds = true;
    
    self.detailViewProfilePicture.layer.cornerRadius = 30;
    self.detailViewProfilePicture.clipsToBounds = true;
    
    
    self.trailingConstraintConstant = self.peopleViewTrailingConstraint.constant;
    self.peopleViewTrailingConstraint.constant = -self.peopleView.bounds.size.width;
    self.isSideBarOpen = false;
    self.detailView.hidden = YES;
    self.detailView.layer.cornerRadius = 3.0f;
    
    UITapGestureRecognizer *mapTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped)];
    mapTapped.numberOfTouchesRequired = 1;
    [self.map addGestureRecognizer:mapTapped];
    self.map.userInteractionEnabled = YES;
    
    [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
	
	self.currentOffset = 0;
	
	[self setTrackingValue:@"Map"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.arrivedLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 45, 20, 20)];
    self.arrivedLabel.backgroundColor = [UIColor colorFromHexString:@"#0D365F"];
    self.arrivedLabel.clipsToBounds = YES;
    self.arrivedLabel.layer.cornerRadius = self.arrivedLabel.bounds.size.height/2.0f;
    self.arrivedLabel.textColor = [UIColor whiteColor];
    self.arrivedLabel.textAlignment = NSTextAlignmentCenter;
    self.arrivedLabel.layer.borderWidth = 2.0f;
    self.arrivedLabel.layer.borderColor = [UIColor whiteColor].CGColor;
	self.orderedPeopleForEvent = [NSMutableArray arrayWithCapacity:0];

	[self prepareMessageView];
    
    CLLocationCoordinate2D eventLocation;
    eventLocation.latitude = [self.event.latitude doubleValue];
    eventLocation.longitude = [self.event.longitude doubleValue];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(eventLocation, MKCoordinateSpanMake(0.005, 0.005));
    [self.map setRegion:region];
    
    [self updateTrackingLabel];
}



-(void)viewDidAppear:(BOOL)animated {
	
    dispatch_async(dispatch_get_main_queue(), ^{
        [super viewDidAppear:animated];
		
        //[self.map removeAnnotations:self.map.annotations];
		
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(requestUpdate) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePeople) name:EVENT_BROADCAST object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareMessageView) name:MESSAGE_BROADCAST object:nil];
    
        self.peopleAtSeedOpen = NO;
    
        self.people = [self.event.persons allObjects];
        self.peopleToAnnotations = [NSMutableDictionary dictionaryWithCapacity:1];
        self.peopleNotTracking = [NSMutableArray arrayWithCapacity:1];
        self.peopleAppendedToEvent = [NSMutableArray arrayWithCapacity:1];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D eventLocation;
        eventLocation.latitude = [self.event.latitude doubleValue];
        eventLocation.longitude = [self.event.longitude doubleValue];
        point.coordinate = eventLocation;
        self.eventAnnotation = point;
        [self.map addAnnotation:point];
    
        for (Person *p in self.people) {
            PersonPointAnnotation *person = [[PersonPointAnnotation alloc] init];
            CLLocationCoordinate2D location;
            location.latitude = [p.latitude doubleValue];
            location.longitude = [p.longitude doubleValue];
            person.coordinate = location;
            person.person = p;
           // [self.map addAnnotation:person];
            [self.peopleToAnnotations setObject:person forKey:p.entId];
        }
    
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate checkForPermission];

        [self updatePeople];
        [self zoomToFitMapAnnotations];
    
        
    });
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self.updateTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_BROADCAST object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_BROADCAST object:nil];
	
    [self.map removeAnnotation:self.eventAnnotation];
    
    [super viewWillDisappear:animated];
}

-(void)requestUpdate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateLists];
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if(annotation == self.eventAnnotation) {
        MKAnnotationView *annView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
        annView.image = [UIImage imageNamed:@"icon_small"];
        annView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        annView.clipsToBounds = NO;
        return annView;
    } else {
        if([annotation isKindOfClass:[PersonPointAnnotation class]]) {
            PersonPointAnnotation *personAnnitation = (PersonPointAnnotation *)annotation;
            MapPinAnnotation *annView=[[MapPinAnnotation alloc] initWithAnnotation:personAnnitation person:personAnnitation.person];
			
            annView.image = [UIImage imageNamed:@"pinbackground"];
            annView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
			
			UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 36, 36)];
			//[imageview setImage:largeProfile];
			
			if(personAnnitation.person.picture != nil) {
				UIImage *image = [UIImage imageWithData:personAnnitation.person.picture];
				[imageview setImage:image];
				
			} else {
				NSURL *url = [NSURL URLWithString:personAnnitation.person.pictureURL];
				[imageview hnk_setImageFromURL:url];
			}
			/*
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:personAnnitation.person.pictureURL]];
            UIImage *largeProfile = [UIImage imageWithData:imageData];
            */
			
            
            imageview.layer.cornerRadius = imageview.bounds.size.height/2.0f;
            imageview.clipsToBounds = YES;
            
            UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 51)];
            [pinImageView setImage:[UIImage imageNamed:@"pin1.png"]];
 
            
            annView.backgroundPin = pinImageView;
            
            pinImageView.layer.anchorPoint = CGPointMake(0.5f, (25.0f/51.0f));
            /*
            float rotation = [personAnnitation.person.heading floatValue];
            
            double rads = ((rotation) / 180.0 * M_PI);
            CGAffineTransform transform = CGAffineTransformRotate(pinImageView.transform, rads);
            pinImageView.transform = transform;
            
            
            imageview.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            double rads2 = ((-rotation) / 180.0 * M_PI);
            CGAffineTransform transform2 = CGAffineTransformRotate(imageview.transform, rads2);
            imageview.transform = transform2;*/
            
            [annView addSubview:pinImageView];
            [pinImageView addSubview:imageview];
            
            return annView;
        }
    }
    return nil;

}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)recenterPressed:(id)sender {
    [self zoomToFitMapAnnotations];
}

- (IBAction)expandSideBarPressed:(id)sender {
    [self toggleSideBar];
}

- (IBAction)donePressed:(id)sender {
    [self toggleOptions];
}

- (IBAction)configPressed:(id)sender {
    [self toggleOptions];
}

- (IBAction)nextOffsetPressed:(id)sender {
	[self.map removeAnnotations:self.map.annotations];
	self.currentOffset += MAP_LIMIT;
	[self updatePeople];
}

- (IBAction)prevOffsetPressed:(id)sender {
	[self.map removeAnnotations:self.map.annotations];
	self.currentOffset -= MAP_LIMIT;
	if(self.currentOffset < 0) self.currentOffset = 0;
	
	[self updatePeople];
}

-(void)toggleOptions {
    if(self.isOptionsOpen) {
        [UIView animateWithDuration:0.5f animations:^{
            self.toolsOverlay.hidden = true;
            self.toolsOverlay.alpha = 0.0f;
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            self.toolsOverlay.hidden = false;
            self.toolsOverlay.alpha = 1.0f;
        }];
    }
    self.isOptionsOpen = !self.isOptionsOpen;
}

-(void)toggleSideBar {
    [self.view layoutIfNeeded];
    
    
    if(self.isSideBarOpen)
        self.peopleViewTrailingConstraint.constant = -self.peopleView.bounds.size.width;
    else {
        [self hideDetail];
        self.peopleViewTrailingConstraint.constant = 0;
    }
    
    self.isSideBarOpen = !self.isSideBarOpen;
    
    [UIView animateWithDuration:.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

-(void)openMessages:(id)sender {
    [self performSegueWithIdentifier: @"openMessages" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openMessages"])
    {
        StatusViewController *vc = [segue destinationViewController];
        
        Event *event = self.event;
        vc.event = event;
    }
    
    else if([[segue identifier] isEqualToString:@"mapToAddPeople"]) {
        AddPeopleViewController *peopleVC = [segue destinationViewController];
		peopleVC.link = self.event.link;
        peopleVC.isFromMap = YES;
    }
    
    else if([[segue identifier] isEqualToString:@"mapToLocationSegue"]) {
        AddLocationViewController *vc = [segue destinationViewController];
        vc.isFromEvent = YES;
        vc.event = self.event;
    }
    
    else if([[segue identifier] isEqualToString:@"mapToTimeSegue"]) {
        AddTimeViewController *vc = [segue destinationViewController];
        vc.isFromEvent = YES;
        vc.event = self.event;
    } else if([[segue identifier] isEqualToString:@"mapToTracking"]) {
        SelectTrackingViewController *vc = [segue destinationViewController];
        vc.event = self.event;
        vc.isFromEvent = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderedPeopleForEvent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Person *person = [self.orderedPeopleForEvent objectAtIndex:indexPath.row];
    

    
    PeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapPersonCell"];


    if(person.picture != nil) {
        UIImage *image = [UIImage imageWithData:person.picture];
        [cell.profilePicture setImage:image];
	
    } else {
        NSURL *url = [NSURL URLWithString:person.pictureURL];
        [cell.profilePicture hnk_setImageFromURL:url];
    }
    
    cell.profilePicture.layer.cornerRadius = 20;
    cell.profilePicture.clipsToBounds = YES;
    
    cell.name.text = person.name;
	
	//if(self.limitingPeople && (indexPath.row > self.currentOffset && //indexPath.row < self.currentOffset + MAP_LIMIT)) {
	//	cell.name.font = [UIFont fontWithName:@"Verdana-Bold" size:12.0];
	//} else {
		cell.name.font = [UIFont fontWithName:@"Verdana" size:12.0];
	//}
    
    cell.backgroundColor = [UIColor clearColor];
    
    if(person.latitude != nil && [person.latitude doubleValue] != 0.0f) {
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:[self.event.latitude doubleValue] longitude:[self.event.longitude doubleValue]];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[person.latitude doubleValue] longitude:[person.longitude doubleValue]];
        CLLocationDistance distance = [locA distanceFromLocation:locB];
        
        if([self isMetric]) {
            cell.distance.text = [self getKilometerDistanceTextFromDistance:distance];
        } else {
            cell.distance.text = [self getMilesDistanceTextFromDistance:distance];
        }
    } else {
        cell.distance.text = NSLocalizedString(@"Not tracking", nil);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Person *person = [self.orderedPeopleForEvent objectAtIndex:indexPath.row];
	
	if([self.peopleToAnnotations objectForKey:person.entId] != nil) {
		MKPointAnnotation *personAnnotation = [self.peopleToAnnotations objectForKey:person.entId];
		
		if([self.peopleAppendedToEvent containsObject:person]) {
			[self.map setCenterCoordinate:self.eventAnnotation.coordinate];
			return;
		}
		/*
		if([self.map.annotations containsObject:personAnnotation]) {
			[self.map addAnnotation:personAnnotation];
		}*/
		
		[self toggleSideBar];
		
		[self showPersonDetail:person];
	}

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showPersonDetail:(Person *) person {
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.detailView.alpha = 1.0f;
                         self.detailView.hidden = false;
                     }];
    
    self.detailViewnameLabel.text = person.name;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:person.pictureURL]];
    UIImage *img = [[UIImage alloc] initWithData:data];
    self.detailViewProfilePicture.image = img;
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:[self.event.latitude doubleValue] longitude:[self.event.longitude doubleValue]];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:[person.latitude doubleValue] longitude:[person.longitude doubleValue]];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    if([self isMetric]) {
        self.detailViewDistanceLabel.text = [self getKilometerDistanceTextFromDistance:distance];
    } else {
        self.detailViewDistanceLabel.text = [self getMilesDistanceTextFromDistance:distance];
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"person = %@",person];
    
    NSArray *result = [[self.event.messages allObjects] filteredArrayUsingPredicate:pred];
    
    MKPointAnnotation *personAnnotation = [self.peopleToAnnotations objectForKey:person.entId];
    /*
    MKPlacemark *personPlacemark = [[MKPlacemark alloc] initWithCoordinate:personAnnotation.coordinate addressDictionary:nil];
    MKMapItem *personMapItem = [[MKMapItem alloc] initWithPlacemark:personPlacemark];
    
    MKPlacemark *eventPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.eventAnnotation.coordinate addressDictionary:nil];
    MKMapItem *eventMapItem = [[MKMapItem alloc] initWithPlacemark:eventPlacemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:personMapItem];
    [request setDestination:eventMapItem];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    [request setRequestsAlternateRoutes:NO];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if ( ! error && [response routes] > 0) {
            MKRoute *route = [[response routes] objectAtIndex:0];

            self.timeToArrivalLabel.text = [NSString stringWithFormat:@"Driving ETA %@",[self stringFromTimeInterval:route.expectedTravelTime]];
        }
    }];*/
    
    if(result != nil) {
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray* sortedResult = [result sortedArrayUsingDescriptors:descriptors];
        Message *lastMessage = [sortedResult lastObject];
        
        if(lastMessage != nil)
            self.detailViewLastStatus.text = lastMessage.message;
        else
            self.detailViewLastStatus.text = NSLocalizedString(@"No status updates.", nil);
    }
    
    [self.map setCenterCoordinate:personAnnotation.coordinate animated:YES];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    MKAnnotationView *annView = [self.map viewForAnnotation:self.eventAnnotation];
    int currentAppend = 0;
    
    
    
    if(annView == view) {
        
        
        
        [self.map deselectAnnotation:self.eventAnnotation animated:NO];
        
       
        
        self.peopleAtSeedOpen = !self.peopleAtSeedOpen;
        if(!self.peopleAtSeedOpen) return;
        
        
        
        for(UIImageView *images in self.imageAnnotationsOnEvent) {
            [images removeFromSuperview];
        }
        
        self.imageAnnotationsOnEvent = [NSMutableArray arrayWithCapacity:1];
        
        self.locationName = [[UILabel alloc] initWithFrame:CGRectMake(22, 45, 20, 20)];
        self.locationName.backgroundColor = [UIColor colorFromHexString:@"#0D365F"];
        self.locationName.clipsToBounds = YES;
       
        self.locationName.textColor = [UIColor whiteColor];
        self.locationName.textAlignment = NSTextAlignmentCenter;
        self.locationName.layer.borderWidth = 2.0f;
        self.locationName.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.locationName.text = self.event.locationName;
        [self.locationName sizeToFit];
        [self.locationName setFrame:CGRectMake(-(self.locationName.bounds.size.width-20.0f)/2.0f, -(self.locationName.bounds.size.height+10.0f), self.locationName.bounds.size.width + 10.0f, self.locationName.bounds.size.height  + 10.0f)];
         self.locationName.layer.cornerRadius = self.arrivedLabel.bounds.size.height/2.0f;
        [annView addSubview:self.locationName];
        
         if(self.peopleAppendedToEvent.count == 0) return;
        if(self.peopleAppendedToEvent.count > 0) {
            
            self.arrivedLabel.hidden = YES;
        
            for(Person *p in self.peopleAppendedToEvent) {
                
                
        
                NSInteger appendedCount = [self.peopleAppendedToEvent count];
                float rotationPercent = 0.0f;
                
                if (appendedCount == 1) {
                    rotationPercent = 0.0f;
                }else {
                    float rotationBase = 180.0 * ((float)currentAppend/(float)(appendedCount-1));
                    rotationPercent =  rotationBase-90.0f;
                }
                
                float offsetnumber = 40.0f;
                
                float radians = DEGREES_TO_RADIANS(rotationPercent);
                
                float xOffset = offsetnumber* sin(radians);
                float yOffset = offsetnumber* cos(radians);
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset+20, 30, 30)];
                
                imageView.clipsToBounds = YES;
                imageView.layer.cornerRadius = imageView.bounds.size.height/2.0;
                imageView.layer.borderColor = [UIColor colorFromHexString:@"#0D365F"].CGColor;
                imageView.layer.borderWidth = 2.0f;
                
                if(p.picture != nil) {
                    UIImage *image = [UIImage imageWithData:p.picture];
                    [imageView setImage:image];
                } else {
                    NSURL *url = [NSURL URLWithString:p.pictureURL];
                    [imageView hnk_setImageFromURL:url];
                }
                
                MKAnnotationView *annView = [self.map viewForAnnotation:self.eventAnnotation];
                
                [annView addSubview:imageView];
                [self.imageAnnotationsOnEvent addObject:imageView];
                
                currentAppend++;
            }
        }
    }
}


-(void)updatePeople {
	
	//This WHOLE update people thing is messy. Fix when time allows.
	
    int currentAppend = 0;
	
	NSMutableArray *peopleTrackingForOrdering = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *peopleNotTrackingForOrdering = [NSMutableArray arrayWithCapacity:1];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSString *currentUserId = delegate.user.entId;

    for(Person *p in [self.event.persons allObjects]) {
		if([self.peopleAppendedToEvent containsObject:p]){
			 PersonPointAnnotation *personAnnotation = [self.peopleToAnnotations objectForKey:p.entId];
			
			NSArray *annotations = self.map.annotations;
			
			for (id ann in annotations) {
				if([ann isKindOfClass:[PersonPointAnnotation class]]) {
					PersonPointAnnotation *pann = (PersonPointAnnotation*)ann;
					
					if([pann.person.entId isEqualToString:p.entId]) {
						[self.map removeAnnotation:ann];
					}
				}
			}
	
			if([self.map.annotations containsObject:personAnnotation]) {
				[self.map removeAnnotation:personAnnotation];
			}
			continue;
		}
		
		if([self.peopleToAnnotations objectForKey:p.entId] == nil) {
			PersonPointAnnotation *person = [[PersonPointAnnotation alloc] init];
			CLLocationCoordinate2D location;
			location.latitude = [p.latitude doubleValue];
			location.longitude = [p.longitude doubleValue];
			person.coordinate = location;
			person.person = p;
			[self.peopleToAnnotations setObject:person forKey:p.entId];
		}
		
		if([p.entId isEqualToString:currentUserId]) continue;
        
        MKPointAnnotation *personAnnotation = [self.peopleToAnnotations objectForKey:p.entId];
        
        if(p.latitude == nil || [p.latitude floatValue] == 0.0) {
			[peopleNotTrackingForOrdering addObject:p];
			
            if(![self.peopleNotTracking containsObject:p]) [self.peopleNotTracking addObject:p];
            if([[self.map annotations] containsObject:personAnnotation]) [self.map removeAnnotation:personAnnotation];
            continue;
        } else {
			
			
			CLLocation *locA = [[CLLocation alloc] initWithLatitude:[self.event.latitude doubleValue] longitude:[self.event.longitude doubleValue]];
			CLLocation *locB = [[CLLocation alloc] initWithLatitude:[p.latitude doubleValue] longitude:[p.longitude doubleValue]];
			CLLocationDistance distance = [locA distanceFromLocation:locB];
			
			BOOL isInTheArea = NO;
			
			if([self isMetric]) {
				isInTheArea = [self isInTheAreaKilometers:distance];
			} else {
				isInTheArea = [self isInTheAreaKilometers:distance];
			}
			
			//isInTheArea = YES;
			
			if(isInTheArea) {
				
				[self.peopleAppendedToEvent addObject:p];
				
				
				currentAppend++;
				
				continue;
			}
			
			NSDictionary *container = [NSDictionary dictionaryWithObjectsAndKeys:p, @"person", [NSNumber numberWithDouble:distance], @"distance", nil];
			
			[peopleTrackingForOrdering addObject:container];

        }
    }
	if(peopleTrackingForOrdering.count > MAP_LIMIT) self.limitingPeople = YES;
	else self.limitingPeople = NO;
	
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
	NSArray *sortedDistanceArray = [peopleTrackingForOrdering sortedArrayUsingDescriptors:@[sort]];
	
	NSArray *arrayToMap;
	
	/*if(self.limitingPeople) {
		
		if(sortedDistanceArray.count> self.currentOffset) {
			NSRange range = NSMakeRange(self.currentOffset, MAP_LIMIT);
			arrayToMap = [sortedDistanceArray subarrayWithRange:range];
		}
		
		self.counterWarp.hidden = false;
		self.totalLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)sortedDistanceArray.count];
		
		if(self.currentOffset + MAP_LIMIT > sortedDistanceArray.count) {
			self.offSetLabel.text = [NSString stringWithFormat:@"%d-%lu", self.currentOffset, (unsigned long)sortedDistanceArray.count];
		} else {
			self.offSetLabel.text = [NSString stringWithFormat:@"%d-%d", self.currentOffset, (self.currentOffset + MAP_LIMIT)];
		}
		
		if(self.currentOffset+MAP_LIMIT >= sortedDistanceArray.count) self.nextSetButton.enabled = FALSE;
		if(self.currentOffset-MAP_LIMIT<=0) self.previousSetButton.enabled = false;
	
	} else {*/
		arrayToMap = sortedDistanceArray;
		self.counterWarp.hidden = YES;
	//}
	
	for(NSDictionary *d in arrayToMap) {
		Person *p = [d valueForKey:@"person"];

		CLLocationCoordinate2D location;
		location.latitude = [p.latitude doubleValue];
		location.longitude = [p.longitude doubleValue];
		
		PersonPointAnnotation *personAnnotationInArray = [self.peopleToAnnotations objectForKey:p.entId];
		PersonPointAnnotation *personAnnotation = nil;

		NSArray *annotations = self.map.annotations;
		
		for (id ann in annotations) {
			if([ann isKindOfClass:[PersonPointAnnotation class]]) {
				PersonPointAnnotation *pann = (PersonPointAnnotation*)ann;
				
				if([pann.person.entId isEqualToString:p.entId]) {
					personAnnotation = pann;
				}
			}
		}
		
	
		
		
		if([self.peopleNotTracking containsObject:p]) {
			[self.peopleNotTracking removeObject:p];
			
			personAnnotation = personAnnotationInArray;
			
			personAnnotation.coordinate = location;
			
			if(![self.map.annotations containsObject:personAnnotation]) {
				
				[self.map addAnnotation:personAnnotation];
			}
		} else {
			
			if(personAnnotation != nil) {
				[UIView animateWithDuration:15.0f
									  delay:0.0
									options:UIViewAnimationOptionCurveLinear
								 animations:^{
									 personAnnotationInArray.coordinate = location;
									 personAnnotation.coordinate = location;
								 } completion:NULL];
			} else {
				personAnnotationInArray.coordinate = location;
				[self.map addAnnotation:personAnnotationInArray];
			}
		}
	}
	
	NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	NSArray *sortedArrivedArray = [self.peopleAppendedToEvent sortedArrayUsingDescriptors:@[nameSort]];
	
	self.orderedPeopleForEvent = [NSMutableArray arrayWithCapacity:1];
	for(Person *p in sortedArrivedArray) {
		[self.orderedPeopleForEvent addObject:p];
	}
	for(NSDictionary *dict in sortedDistanceArray) {
		Person *p = [dict valueForKey:@"person"];
		[self.orderedPeopleForEvent addObject:p];
	}
	
	NSArray *sortedNotTrackingArray = [self.peopleNotTracking sortedArrayUsingDescriptors:@[nameSort]];
	for(Person *p in sortedNotTrackingArray) {
		[self.orderedPeopleForEvent addObject:p];
	}

    MKAnnotationView *annView = [self.map viewForAnnotation:self.eventAnnotation];
	
	
    self.arrivedLabel.text = [NSString stringWithFormat:@"%d", currentAppend];
	
    [annView addSubview:self.arrivedLabel];
	
    if(currentAppend == 0) {
        self.arrivedLabel.hidden = YES;
    }
	
    [self.peopleTable reloadData];
    
    [self updateTrackingLabel];
	
	[self prepareMessageView];

}

-(void)prepareMessageView {
	if(self.event.messages != nil && self.event.messages.count > 0) {
		self.noStatusLabel.hidden = true;
		self.lastStatusDisplay.hidden = false;
		
		NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:YES];
		NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
		NSArray *messages = [self.event.messages sortedArrayUsingDescriptors:descriptors];
		
		Message *lastMessage = [messages lastObject];
		
		self.lastStatusLabel.text = lastMessage.message;
		
		
		
		if(lastMessage.person != nil) {
			//                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:lastMessage.person.pictureURL]];
			//                UIImage *img = [[UIImage alloc] initWithData:data];
			//                self.lastStatusProfilePicture.image = img;
			
			if(lastMessage.person.picture != nil) {
				UIImage *image = [UIImage imageWithData:lastMessage.person.picture];
				[self.lastStatusProfilePicture setImage:[UIImage scaleAndRotateImage:image]];
			} else {
				NSURL *url = [NSURL URLWithString:lastMessage.person.pictureURL];
				[self.lastStatusProfilePicture hnk_setImageFromURL:url];
			}
			
			self.lastStatusProfilePicture.contentMode = UIViewContentModeScaleAspectFill;
			
			self.lastStatusName.text = lastMessage.person.name;
			
			if(lastMessage.person.isUser) {
				self.lastStatusName.textColor = [UIColor colorFromHexString:@"#5F5225"];
			}
		}
		
	} else {
		self.noStatusLabel.hidden = false;
		self.lastStatusDisplay.hidden = true;
	}
}

-(void)mapTapped {
	if(self.isSideBarOpen) [self toggleSideBar];
	[self hideDetail];
}

-(void)hideDetail {
	
    for(UIImageView *images in self.imageAnnotationsOnEvent) {
        [images removeFromSuperview];
    }
    
    self.imageAnnotationsOnEvent = [NSMutableArray arrayWithCapacity:1];
    if(self.peopleAppendedToEvent.count > 0) {
        self.arrivedLabel.hidden = false;
    }
    if(self.locationName != nil) {
        [self.locationName removeFromSuperview];
        self.locationName = nil;
    }
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.detailView.alpha = 0.0f;
                         self.detailView.hidden = true;
                     }];
}


-(void)zoomToFitMapAnnotations
{
    if([self.map.annotations count] == 1) {
        //MKMapPoint annotationPoint = MKMapPointForCoordinate(self.eventAnnotation.coordinate);
        //MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 20, 20);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.eventAnnotation.coordinate, MKCoordinateSpanMake(0.005, 0.005));
        [self.map setRegion:region];
        return;
    } else if([self.map.annotations count] == 0) {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id <MKAnnotation> annotation in self.map.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.25; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.25; // Add a little extra space on the sides
    
    region = [self.map regionThatFits:region];
    [self.map setRegion:region animated:NO];
}

-(NSString *)getMilesDistanceTextFromDistance:(double) distance {
    float miles = distance/1609.344;
    if(miles < 0.15) {
        return NSLocalizedString(@"In the area", nil);
    } else if (miles < 1.05) {
        return  [NSString stringWithFormat:NSLocalizedString(@"%.0f yards", nil), (distance / 1.09361f)];
    } else {
		if(miles == 1) return [NSString stringWithFormat:NSLocalizedString(@"%.0f mile", nil), miles];
       else return [NSString stringWithFormat:NSLocalizedString(@"%.0f miles", nil), miles];
    }
}

-(NSString *)getKilometerDistanceTextFromDistance:(double) distance {
    float kilometers = distance/1000.0f;
    if(kilometers < 0.15) {
        return NSLocalizedString(@"In the area", nil);
    } else if (kilometers < 1.05) {
        return  [NSString stringWithFormat:NSLocalizedString(@"%.0f meters", nil), distance];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"%.0f km", nil), kilometers];
    }
}

-(BOOL)isInTheAreaMiles:(double) distance {
    float miles = distance/1609.344;
    if(miles < 0.1) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isInTheAreaKilometers:(double) distance {
    float miles = distance/1000.0f;
    if(miles < 0.1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if(hours > 0) {
        return [NSString stringWithFormat:@"> %ld hours", hours];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
}

- (BOOL)isMetric {
    return [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

- (IBAction)startTrackingNow:(id)sender {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate eventsTracking] != nil && [[delegate eventsTracking] containsObject:self.event]) {
        [self.event setForcedNoTracking:[NSNumber numberWithBool:YES]];
    } else {
        NSTimeInterval timeAmount = [self.event.datetime timeIntervalSinceNow];
        timeAmount += 5;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.event setForcedNoTracking:[NSNumber numberWithBool:NO]];
        [self.event setStartTracking:[NSNumber numberWithInt:timeAmount]];
    }
    
    
    [delegate saveContext];
    [delegate getEventsForTracking];
    
    [self updateTrackingLabel];
    
}

-(void)updateTrackingLabel {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate eventsTracking] != nil && [[delegate eventsTracking] containsObject:self.event]) {
        [self.startTrackingButton setTitle:NSLocalizedString(@"Stop Tracking", nil) forState:UIControlStateNormal];
    } else {
        [self.startTrackingButton setTitle:NSLocalizedString(@"Start Tracking Now", nil) forState:UIControlStateNormal];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
