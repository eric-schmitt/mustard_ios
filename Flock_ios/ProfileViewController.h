//
//  ProfileViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 5/4/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MustardViewController.h"

@interface ProfileViewController : MustardViewController
<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileHelpLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property BOOL hasSetImage;

-(void)openMediaPickerWithType:(UIImagePickerControllerSourceType)type;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *profileTitle;

@end
