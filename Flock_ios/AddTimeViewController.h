//
//  AddTimeViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "MustardViewController.h"

@interface AddTimeViewController : MustardViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *startNowButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orImage;

@property Event *event;
@property BOOL isFromEvent;

- (IBAction)startNowPressed:(id)sender;

@end
