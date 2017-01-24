//
//  ProfileViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 5/4/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "ProfileViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIView+Toast.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"
#import "UIColor+HexString.h"
#import "Person.h"
#import "UIImage+ProperRotation.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.profilePicture.translatesAutoresizingMaskIntoConstraints = false;
	self.profilePicture.hidden = false;
	self.profilePicture.alpha = 1.0f;
    self.profilePicture.layer.cornerRadius = 75;
    self.profilePicture.clipsToBounds = YES;
    self.hasSetImage = YES;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadPhoto:)];
    gr.numberOfTouchesRequired = 1;
    [self.profilePicture addGestureRecognizer:gr];
    self.profilePicture.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *keyboardDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss:)];
    keyboardDismiss.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:keyboardDismiss];
    self.view.userInteractionEnabled = YES;
    
    self.nameField.layer.borderColor = [UIColor colorFromHexString:@"#FDD447"].CGColor;
    self.nameField.layer.borderWidth = 1.0f;
    self.nameField.layer.cornerRadius = 2.0f;

    self.facebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.profileHelpLabel.text = NSLocalizedString(@"Upload a photo of yourself... or your dog. Really, anything is fine.", nil);
    self.nameField.placeholder = NSLocalizedString(@"Give us a name!", nil);

    [self.facebookButton setTitle:NSLocalizedString(@"Update with Facebook", nil) forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Person *user = [delegate user];
    
    if(user) {
        self.nameField.text = user.name;
        if(user.picture != nil) {
            UIImage *image = [UIImage imageWithData:user.picture];
            [self.profilePicture setImage:[UIImage imageWithCGImage:image.CGImage scale:1 orientation:image.imageOrientation]];
        }
    }
    
    self.profileTitle.text = NSLocalizedString(@"Profile", nil);
	
	 [self setTrackingValue:@"Update Profile"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)donePressed:(id)sender {
    if(self.hasSetImage && self.nameField.text.length > 0) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Person *person = [delegate user];
        
         [self.doneButton setEnabled:NO];
        [self startLoadingScreen];
        
        [[API sharedAPI] sendUpdateProfile:person.entId :self.profilePicture.image :self.nameField.text completion:^(APIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(response.code == 200 || response.code == 204) {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.nameField.text forKey:@"username"];
                    [defaults setObject:UIImageJPEGRepresentation(self.profilePicture.image,1) forKey:@"profile_picture"];
                    
                    if(response.body.length == 0) {
                        [self showError:NSLocalizedString(@"Could not connect.", nil)];
                        return;
                    }
                    
                    Person *user = [delegate user];
                    [user setName:self.nameField.text];
                    [user setPicture:UIImageJPEGRepresentation(self.profilePicture.image, 1)];
                    
                    [delegate saveContext];
                    
                    [delegate setUser:person];
                    
                    //[delegate changeToList];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else if(response.code == INTERNAL_ERROR || response.code == NOT_FOUND_ERROR) {
                    [self showError:response.comment];
                }
                [self.doneButton setEnabled:YES];
                
                [self stopLoadingScreen];
            });

        }];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.nameField.text forKey:@"username"];
        [defaults setObject:UIImagePNGRepresentation(self.profilePicture.image) forKey:@"profile_picture"];
        
       
        
    } else {
        
        [self showError:NSLocalizedString(@"Enter a name and give a photo! It's for your friends, not us.", nil)];
        
    }
}

-(void)showError:(NSString *)error {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageAlignment = NSTextAlignmentCenter;
    [self.view makeToast:error
                duration:3.0
                position:CSToastPositionTop
                   style:style];
}

-(void)uploadPhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIButton *button = tap.view;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *media = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Media library", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action)
                            {
                                [self openMediaPickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
                            }];
    
    UIAlertAction *camera = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Take a photo", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action)
                             {
                                 [self openMediaPickerWithType:UIImagePickerControllerSourceTypeCamera];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alertController addAction:media];
    [alertController addAction:camera];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = button;
        popover.sourceRect = button.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}

-(void)openMediaPickerWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = type;
    controller.allowsEditing = NO;
    controller.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    controller.delegate = self;
    [self presentViewController: controller animated: YES completion: nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    //NSData *imageData = UIImagePNGRepresentation(image);
    [self.profilePicture setImage:image];
    [self.profileHelpLabel setHidden:YES];
    self.hasSetImage = YES;
}

-(void)keyboardDismiss:(id)sender {
    [self.nameField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)loginWithFacebook:(id)sender {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [self fillDetailsWithFacebook:result];
             }
         }];
    } else {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"fb://"]])
        {
            login.loginBehavior = FBSDKLoginBehaviorNative;
        } else {
            login.loginBehavior = FBSDKLoginBehaviorWeb;
        }
        
        [login
         logInWithReadPermissions: @[@"public_profile"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 if ([FBSDKAccessToken currentAccessToken]) {
                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name"}]
                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                          if (!error) {
                              [self fillDetailsWithFacebook:result];
                          }
                      }];
                 }
             }
         }];
    }
}

-(void)fillDetailsWithFacebook:(id)result {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",result[@"id"]]];
    NSData  *data = [NSData dataWithContentsOfURL:url];
    [self.profilePicture setImage:[UIImage imageWithData:data]];
    if(result[@"name"] != nil)
        [self.nameField setText:result[@"name"]];
    
    [self.profileHelpLabel setHidden:YES];
    self.hasSetImage = YES;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
