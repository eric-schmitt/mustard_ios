//
//  RegisterViewController.m
//  Flock_ios
//
//  Created by Eric Schmitt on 4/6/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "RegisterViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIView+Toast.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"
#import "UIColor+HexString.h"
#import "APIResponse.h"
#import "Person.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasSetImage = NO;
    
    self.profilePicture.layer.cornerRadius = 75;
    self.profilePicture.clipsToBounds = YES;
    
    
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
    self.doneButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.facebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.doneButton.layer.cornerRadius = 3.0f;
    
    self.profileHelpLabel.text = NSLocalizedString(@"Upload a photo of yourself... or your dog. Really, anything is fine.", nil);
    self.nameField.placeholder = NSLocalizedString(@"Give us a name!", nil);
    
    [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.facebookButton setTitle:NSLocalizedString(@"Login with Facebook", nil) forState:UIControlStateNormal];
    
    [self setStatusBarBackgroundColor];
	
	[self setTrackingValue:@"Register"];
}

- (void)didReceiveMemoryWarning {
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

- (IBAction)donePressed:(id)sender {
    if(self.hasSetImage && self.nameField.text.length > 0) {
  
        [self.doneButton setEnabled:NO];
        [self startLoadingScreen];
        //AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //[delegate changeToList];

        [[API sharedAPI] sendRegistration:self.profilePicture.image :self.nameField.text completion:^(APIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(response.code == 200 || response.code == 204) {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.nameField.text forKey:@"username"];
                    [defaults setObject:UIImageJPEGRepresentation(self.profilePicture.image,1) forKey:@"profile_picture"];
                    
                    if(response.body.length == 0 || [response.responseDictionary objectForKey:@"userId"]==nil) {
                        [self showError:NSLocalizedString(@"Could not register.", nil)];
                        return;
                    }
                    
                    NSString *entId = (NSString *)[response.responseDictionary objectForKey:@"userId"];
                    
                    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[delegate managedObjectContext]];
                    [person setName:self.nameField.text];
                    [person setEntId:entId];
                    [person setPicture:UIImageJPEGRepresentation(self.profilePicture.image,1)];
                   // [person setPictureURL:@"https://graph.facebook.com/790769036/picture?type=large"];
                    [person setIsUser:[NSNumber numberWithBool:YES]];
                    
                    [delegate saveContext];
                    
                    [delegate setUser:person];
                    
                    [self performSegueWithIdentifier:@"RegisteredSegue" sender:self];

                } else if(response.code == INTERNAL_ERROR) {
                    [self showError:response.comment];
                }
                [self.doneButton setEnabled:YES];
                [self stopLoadingScreen];
            });
        }];
        
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showError:NSLocalizedString(@"Enter a name and give a photo! It's for your friends, not us.", nil)];
        });
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

- (void)setStatusBarBackgroundColor{
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor colorFromHexString:@"#B09025"];
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
