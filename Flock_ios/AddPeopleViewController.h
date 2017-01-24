//
//  AddPeopleViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/15/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Event.h"
#import "MustardViewController.h"

@interface AddPeopleViewController : MustardViewController <MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *recentButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *contactButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *otherButton;
@property (weak, nonatomic) IBOutlet UIView *addContactsPopup;
@property (strong, nonatomic) NSMutableArray *contactsInPhone;
@property (weak, nonatomic) IBOutlet UITableView *contactTable;
@property(strong, nonatomic) NSMutableArray *rowsToSelect;

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSString *link;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property NSString *currentSource;
@property bool isFromMap;

@property (weak, nonatomic) IBOutlet UIButton *addContactsbutton;
@property (weak, nonatomic) IBOutlet UIButton *addFacebookButton;
@property (weak, nonatomic) IBOutlet UILabel *addPeopleDescription;
@property (weak, nonatomic) IBOutlet UILabel *addPeoplTitle;

- (IBAction)closePopupPressed:(id)sender;
- (IBAction)addFromContactPressed:(id)sender;
- (IBAction)addFromFacebookPressed:(id)sender;
- (void)showContactsRejectedPopup;
- (IBAction)closeFacebookPopup:(id)sender;
- (IBAction)nextButton:(id)sender;
- (IBAction)backButton:(id)sender;

@end
