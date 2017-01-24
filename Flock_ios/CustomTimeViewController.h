//
//  CustomTimeViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/18/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "MustardViewController.h"

@interface CustomTimeViewController : MustardViewController
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTable;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property Event *event;
@property BOOL isFromEvent;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;



- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@end
