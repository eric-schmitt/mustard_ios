//
//  AddPeopleViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/15/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "AddPeopleViewController.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "PersonInList.h"
#import "AddPersonTableViewCell.h"
#import "UIColor+HexString.h"
#import "ContactDetail.h"
#import "AddPersonPhoneNumberCell.h"
#import "AddSeedData.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "ListViewController.h"
#import "MapViewController.h"
#import "JoinSeedViewController.h"

@interface AddPeopleViewController ()

@end

@implementation AddPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *controllersToKeep = [NSMutableArray arrayWithCapacity:1];
    for(UIViewController *controller in self.navigationController.childViewControllers) {
        if([controller isKindOfClass:[ListViewController class]] || [controller isKindOfClass:[MapViewController class]]) {
            [controllersToKeep addObject:controller];
        }
        
    }
    
    [controllersToKeep addObject:self];
    
    [self.navigationController setViewControllers:controllersToKeep];
    
    [self.addContactsbutton setTitle:NSLocalizedString(@"Add From Contact List", nil) forState:UIControlStateNormal];
    [self.addFacebookButton setTitle:NSLocalizedString(@"Add From Facebook", nil) forState:UIControlStateNormal];
    
    if(self.isFromMap == YES)
        [self.nextButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    else
        [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    self.addPeopleDescription.text = NSLocalizedString(@"Where would you like to add people from?", nil);
    self.addPeoplTitle.text = NSLocalizedString(@"Add People", nil);
	
	[self setTrackingValue:@"Add People"];
    
    /*
    NSMutableArray *mutableItems = [self.toolbarItems mutableCopy];
    [mutableItems removeObject:self.otherButton];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"pickedContactType"] == nil) {
        [mutableItems removeObject:self.recentButton];
        
    } else {
        
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"enabledContacts"] == nil) {
        [mutableItems removeObject:self.contactButton];
        [mutableItems removeObject:self.otherButton];
        [mutableItems addObject:self.otherButton];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"enabledFacebook"] == nil) {
        [mutableItems removeObject:self.facebookButton];
        [mutableItems removeObject:self.otherButton];
        [mutableItems addObject:self.otherButton];
    }
    
    self.rowsToSelect = [NSMutableArray arrayWithCapacity:1];*/
    
    //[self setToolbarItems:mutableItems animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButton:(id)sender {
    if(self.isFromMap) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"JoinAddSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"JoinAddSegue"]) {
        JoinSeedViewController *vc = [segue destinationViewController];
        vc.event = self.event;
    }
}



- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closePopupPressed:(id)sender {
    [UIView animateWithDuration:0.5f animations:^(void){
        self.addContactsPopup.hidden = true;
        self.addContactsPopup.alpha = 0.0f;
    }];
}

#pragma mark - FACEBOOK

-(IBAction)addFromFacebookPressed:(id)sender {
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger-api://"]]) {
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:self.link];
        content.contentTitle = NSLocalizedString(@"Meetup With Mustard!", nil);

       //[FBSDKMessageDialog showFromViewController:self withContent:content delegate:nil];
        [FBSDKMessageDialog showWithContent:content delegate:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh Oh!", nil)
                                                        message:NSLocalizedString(@"Adding with Facebook requires Facebook Messenger.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh Oh!", nil) message:NSLocalizedString(@"Failed to send message.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK!", nil) otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - CONTACTS

- (IBAction)addFromContactPressed:(id)sender {
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        [picker setBody: [NSString stringWithFormat:NSLocalizedString(@"You have been invited to a Mustard Seed! Click the link below to join! \n\n %@", nil), self.link]];
        
        [self presentViewController:picker animated:YES completion:nil];
    }  else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh Oh!", nil)
                                                        message:NSLocalizedString(@"It doesn't seem like this device cannot send messages. Might I recommend using one of our other services?", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
    /*
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        
        [self showContactsRejectedPopup];
        
        return;
    }
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"9.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            

            
            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContactsRejectedPopup];
                });
                return;
            }
            
            
           self.contactsInPhone = [NSMutableArray arrayWithCapacity:1];
            
            NSError *fetchError;
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey]];
            
            CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
            
            BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
                if(contact.phoneNumbers.count > 0) {
                    PersonInList *personInList = [[PersonInList alloc] init];
                    [personInList setName:[formatter stringFromContact:contact]];
                    
                    NSMutableArray *phonesForContact = [NSMutableArray arrayWithCapacity:1];
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        ContactDetail *detail = [[ContactDetail alloc] init];
                        detail.contactNumber = [label.value stringValue];
                        detail.label = label.label;
                        [phonesForContact addObject:detail];
                    }
                    
                    
                    [personInList setPhoneNumbers:phonesForContact];
                    [personInList setIsFacebook:NO];
                    
                    [self.contactsInPhone addObject:personInList];
                }
            }];
            if (!success) {
                NSLog(@"error = %@", fetchError);
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentSource = @"Contacts";
                [self.contactTable reloadData];
            });

        }];
    } else {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                    [self processContacts:addressBookRef];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.currentSource = @"Contacts";
                        [self.contactTable reloadData];
                    });
                }
                else {
                    [self showContactsRejectedPopup];
                }
                if(addressBookRef) CFRelease(addressBookRef);
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self processContacts:addressBookRef];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentSource = @"Contacts";
                [self.contactTable reloadData];
            });
            if(addressBookRef) CFRelease(addressBookRef);
        }
        else {
            [self showContactsRejectedPopup];
            if(addressBookRef) CFRelease(addressBookRef);
        }
    }
    
    
    
    [UIView animateWithDuration:0.5f animations:^(void){
        self.addContactsPopup.hidden = true;
        self.addContactsPopup.alpha = 0.0f;
    }];
    
    
}


-(void)processContacts:(ABAddressBookRef) addressBook {
    self.contactsInPhone = [NSMutableArray arrayWithCapacity:1];
    CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSArray *contacts = (__bridge NSArray*)records;
    CFRelease(records);
    
    for(int i = 0; i < contacts.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)[contacts objectAtIndex:i];
        
        ABMultiValueRef phonesRef = ABRecordCopyValue(record, kABPersonPhoneProperty);
        
        if(phonesRef) {
            long count = ABMultiValueGetCount(phonesRef);
            
            if(count>0) {
                
                PersonInList *personInList = [[PersonInList alloc] init];
                NSString *name = @"";
                
                 NSString *firstName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
                
                
                BOOL firstNameFirst = (ABPersonGetCompositeNameFormatForRecord(NULL)==kABPersonCompositeNameFormatFirstNameFirst);
                
                if(firstName == nil) {
                    firstName = (__bridge NSString *)ABRecordCopyValue(phonesRef, kABPersonFirstNamePhoneticProperty);
                }
                
                if(lastName == nil) {
                    lastName = (__bridge NSString *)ABRecordCopyValue(phonesRef, kABPersonLastNamePhoneticProperty);
                }
                
                if(firstName == nil && lastName==nil) {
                    name= NSLocalizedString(@"No name record.", nil);
                } else {
                    if(firstNameFirst)
                        name = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                    else
                        name = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                }

                
                [personInList setName:name];
                
                NSMutableArray *phonesForContact = [NSMutableArray arrayWithCapacity:1];
                
                for(int ix = 0; ix < count; ix++){
                    CFStringRef typeTmp = ABMultiValueCopyLabelAtIndex(phonesRef, ix);
                    CFStringRef numberRef = ABMultiValueCopyValueAtIndex(phonesRef, ix);
                    CFStringRef typeRef = ABAddressBookCopyLocalizedLabel(typeTmp);
                    
                    NSString *phoneNumber = (__bridge NSString *)numberRef;
                    NSString *phoneType = (__bridge NSString *)typeRef;
                    
                    ContactDetail *detail = [[ContactDetail alloc] init];
                    detail.contactNumber = phoneNumber;
                    detail.label = phoneType;
                    [phonesForContact addObject:detail];
                    
                    
                    
                    
                    
                    if(typeTmp) CFRelease(typeTmp);
                    if(numberRef) CFRelease(numberRef);
                    if(typeRef) CFRelease(typeRef);
                }
                [personInList setPhoneNumbers:[phonesForContact copy]];
                [personInList setIsFacebook:NO];
                [self.contactsInPhone addObject:personInList];
                CFRelease(phonesRef);
            }
        }
    }
}

-(void)showContactsRejectedPopup {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"Mustard was previously refused permissions to contacts; Please go to settings and grant permission to import contacts", nil)
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *settings = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Open Settings", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"root=Privacy&path=CONTACTS"]];
                               }];
    
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alertController addAction:settings];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.addContactsbutton;
        popover.sourceRect = self.addContactsbutton.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}

- (IBAction)closeFacebookPopup:(id)sender {
}

#pragma mark - TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.currentSource isEqualToString:@"Contacts"])
        return self.contactsInPhone.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if([self.currentSource isEqualToString:@"Contacts"]) {
    
        if([[self.contactsInPhone objectAtIndex:indexPath.row] isKindOfClass:[PersonInList class]]) {
            AddPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddPersonCell" forIndexPath:indexPath];
            
            if (!cell) {
                cell = [[AddPersonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddPersonCell"];
            }
            
            PersonInList *person = [self.contactsInPhone objectAtIndex:indexPath.row];
            
            cell.personName.text = person.name;
            cell.originalItem = person;
            cell.childrenCells = [[NSMutableArray alloc] initWithCapacity:1];
            
            UIView *bgColorView = [[UIView alloc] init];
            bgColorView.backgroundColor = [UIColor colorFromHexString:@"#F5D04C"];
            [cell setSelectedBackgroundView:bgColorView];
            return cell;
        } else if([[self.contactsInPhone objectAtIndex:indexPath.row] isKindOfClass:[ContactDetail class]]) {
            AddPersonPhoneNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneNumberCell" forIndexPath:indexPath];
            
            if (!cell) {
                cell = [[AddPersonPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PhoneNumberCell"];
            }
            
            ContactDetail *detail = [self.contactsInPhone objectAtIndex:indexPath.row];
            
            cell.phoneNumber.text = detail.contactNumber;
            cell.typeLabel.text = detail.label;
            cell.contactDetail = detail;
            
            if(detail.parentPath != nil) {
                cell.parent = [self.contactTable cellForRowAtIndexPath:detail.parentPath];
                if(cell.parent != nil && cell.parent.childrenCells != nil) {
                    [cell.parent.childrenCells addObject:cell];
                }
            }
            
            UIView *bgColorView = [[UIView alloc] init];
            bgColorView.backgroundColor = [UIColor colorFromHexString:@"#F5D04C"];
            [cell setSelectedBackgroundView:bgColorView];
            return cell;
        }
    }
        
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[self.contactTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AddPersonTableViewCell class]]) {
        
        AddPersonTableViewCell *cell = [self.contactTable cellForRowAtIndexPath:indexPath];
 
        if(cell.isOpen) {
            for(AddPersonPhoneNumberCell *childCell in cell.childrenCells) {
                BOOL otherCellSelected = NO;
                if(childCell.isSelected) {
                    otherCellSelected = YES;
                }
                if(!otherCellSelected) [self.contactTable deselectRowAtIndexPath:indexPath animated:YES];
                
                for(AddPersonPhoneNumberCell *childCell in cell.childrenCells) {
                    [[[AddSeedData seedData] selectedPeople] removeObject:childCell.contactDetail];
                }
                cell.isOpen = NO;
                
                NSMutableArray *indexesToRemove = [NSMutableArray arrayWithCapacity:1];
                
                for(AddPersonPhoneNumberCell *childCell in cell.childrenCells) {
                    [self.contactsInPhone removeObject:childCell.contactDetail];
                    [[[AddSeedData seedData] selectedPeople] removeObject:childCell.contactDetail];
                    NSIndexPath *childIndex = [self.contactTable indexPathForCell:childCell];
                    if(childIndex != nil)
                        [indexesToRemove addObject:childIndex];
                }
                
                [self.contactTable beginUpdates];
                [self.contactTable deleteRowsAtIndexPaths:[indexesToRemove copy] withRowAnimation:UITableViewRowAnimationTop];
                [self.contactTable endUpdates];
            }
        } else {
            if(cell.originalItem != nil) {
                PersonInList *person = cell.originalItem;
                if(person != nil) {
                    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
                    NSUInteger insertedCount = 0;
                    
                    for (ContactDetail *detail in person.phoneNumbers) {
                        [self.contactsInPhone insertObject:detail atIndex:indexPath.row+1];
                        detail.parentPath = indexPath;
                        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+insertedCount+1 inSection:indexPath.section]];
                        insertedCount++;
                    }
                    
                    if(indexPaths.count == 1) {
                        [self.rowsToSelect addObject:[indexPaths objectAtIndex:0]];
                    } else {
                        [self.contactTable deselectRowAtIndexPath:indexPath animated:YES];
                    }

                    cell.isOpen = YES;
                     
                     [self.contactTable beginUpdates];
                     [self.contactTable insertRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationTop];
                     [self.contactTable endUpdates];

                }
            }
        }
    } else if([[self.contactTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AddPersonPhoneNumberCell class]]) {
         AddPersonPhoneNumberCell *cell = [self.contactTable cellForRowAtIndexPath:indexPath];
        if(cell.parent != nil) {
            for(AddPersonPhoneNumberCell *childCell in cell.parent.childrenCells) {
                if(childCell != cell) {
                    if(childCell.isSelected) {
                        NSIndexPath *childPath = [self.contactTable indexPathForCell:childCell];
                        [self.contactTable deselectRowAtIndexPath:childPath animated:YES];
                    }
                }
            }
            
            if(!cell.parent.isSelected) {
                 NSIndexPath *parentCellIndex = [self.contactTable indexPathForCell:cell.parent];
                [self.contactTable selectRowAtIndexPath:parentCellIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
            }

            [[[AddSeedData seedData] selectedPeople] addObject:cell.contactDetail];
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([[self.contactTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AddPersonTableViewCell class]]) {
        AddPersonTableViewCell *cell = [self.contactTable cellForRowAtIndexPath:indexPath];
        for(AddPersonPhoneNumberCell *childCell in cell.childrenCells) {
            [[[AddSeedData seedData] selectedPeople] removeObject:childCell.contactDetail];
        }
        cell.isOpen = NO;
        
        NSMutableArray *indexesToRemove = [NSMutableArray arrayWithCapacity:1];
        
        for(AddPersonPhoneNumberCell *childCell in cell.childrenCells) {
            [self.contactsInPhone removeObject:childCell.contactDetail];
            [[[AddSeedData seedData] selectedPeople] removeObject:childCell.contactDetail];
            NSIndexPath *childIndex = [self.contactTable indexPathForCell:childCell];
            [indexesToRemove addObject:childIndex];
        }
        
        [self.contactTable beginUpdates];
        [self.contactTable deleteRowsAtIndexPaths:[indexesToRemove copy] withRowAnimation:UITableViewRowAnimationTop];
        [self.contactTable endUpdates];
    } else if([[self.contactTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AddPersonPhoneNumberCell class]]) {
        AddPersonPhoneNumberCell *cell = [self.contactTable cellForRowAtIndexPath:indexPath];
        [[[AddSeedData seedData] selectedPeople] removeObject:cell.contactDetail];
        
        BOOL otherCellSelected = NO;
        
        for(AddPersonPhoneNumberCell *childCell in cell.parent.childrenCells) {
            if(childCell != cell) {
                if(childCell.isSelected) {
                    otherCellSelected = YES;
                }
            }
        }
       
        if(!otherCellSelected) {
             NSIndexPath *parentCellIndex = (AddPersonTableViewCell*)[self.contactTable indexPathForCell:cell.parent];
            [self.contactTable deselectRowAtIndexPath:parentCellIndex animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.rowsToSelect containsObject:indexPath]) {
        [cell setSelected:YES animated:NO];
        [self.rowsToSelect removeObject:indexPath];
    }
}*/


@end
