//
//  AddLocationNameViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/14/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "MustardViewController.h"

@interface AddLocationNameViewController : MustardViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)nextButton:(id)sender;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *controls;
@property BOOL isFromEvent;

@end
