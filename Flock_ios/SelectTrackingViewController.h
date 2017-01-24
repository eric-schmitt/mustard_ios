//
//  SelectTrackingViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 5/4/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "MustardViewController.h"

@interface SelectTrackingViewController : MustardViewController <UITableViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSArray *presetTime;
@property float timeAmount;
@property BOOL isFromEvent;

@property (weak, nonatomic) IBOutlet UILabel *gettingSeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *gettingSeedDetail;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *trackingLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UITableView *timeTable;

@property Event *event;
@property BOOL selectedCustom;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;


@end
