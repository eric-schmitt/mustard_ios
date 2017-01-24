//
//  AddNameViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MustardViewController.h"

@interface AddNameViewController : MustardViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
- (IBAction)nextButton:(id)sender;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *controls;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
