//
//  AddNameViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/13/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddNameViewController.h"
#import "AddTimeViewController.h"
#import "UIView+Toast.h"
#import "AddSeedData.h"
#import "UIColor+HexString.h"

@interface AddNameViewController ()

@end

@implementation AddNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.inputAccessoryView.translatesAutoresizingMaskIntoConstraints = true;
	
    [self.controls removeFromSuperview];
    
    self.nameText.text = NSLocalizedString(@"Give a name", nil);
	
	self.nextButton.translatesAutoresizingMaskIntoConstraints = false;
	self.cancelButton.translatesAutoresizingMaskIntoConstraints = false;
    
    self.nameTextBox.layer.cornerRadius = 3.0f;
    self.nameTextBox.layer.borderColor = [UIColor colorFromHexString:@"#FDD447"].CGColor;
    
    [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
	[self setTrackingValue:@"Create Flow - Add Name"];
}

- (void)didReceveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextButton:(id)sender {
    if(self.nameTextBox.text.length > 0) {
        [[AddSeedData seedData] setSeedName:self.nameTextBox.text];
        [self performSegueWithIdentifier:@"timeSegue" sender:self];
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageAlignment = NSTextAlignmentCenter;
        [self.view makeToast:NSLocalizedString(@"Enter a name.", nil)
                    duration:1.5
                    position:CSToastPositionTop
                       style:style];
    }
}

- (IBAction)backButton:(id)sender {
    [[AddSeedData seedData] clearData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

- (UIView *)inputAccessoryView{
    
    return self.controls;
	
	NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.controls
																		attribute:NSLayoutAttributeHeight
																		relatedBy:NSLayoutRelationEqual
																		   toItem:nil
																		attribute:NSLayoutAttributeNotAnAttribute
																	   multiplier:1.0
																		 constant:52];
	
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
