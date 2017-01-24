//
//  StatusViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/10/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "StatusViewController.h"
#import "QuickStatusViewController.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "Message.h"
#import "Haneke.h"
#import "UIImageView+Haneke.h"
#import "AppDelegate.h"
#import "UIImage+ProperRotation.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.inputAccessoryView.translatesAutoresizingMaskIntoConstraints = true;
    
    self.messageTextField.placeholder = NSLocalizedString(@"Type your status here...", nil);
    
    [self.messageTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, 10.0f, 0.f)];
    
    self.messageTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.lastCellLeft = false;
    
    self.leftCell = @"leftCell";
    self.rightCell = @"rightCell";
    self.leftMessageOnly = @"messageOnlyLeftCell";
    self.rightMessageOnly = @"messageOnlyRightCell";

	self.messageTable.rowHeight = UITableViewAutomaticDimension;
	self.messageTable.estimatedRowHeight = 60;
    
    if(self.event == nil) [self.navigationController popViewControllerAnimated:NO];
    
    
    
  //  UITapGestureRecognizer *keyboardDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss:)];
 //   keyboardDismiss.numberOfTouchesRequired = 1;
  //  [self.view addGestureRecognizer:keyboardDismiss];
  //  self.view.userInteractionEnabled = YES;
    
    self.statusTitle.text =  self.event.title;
    [self.sendMessageView removeFromSuperview];
	
	[self setTrackingValue:@"Status"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessages:) name:MESSAGE_BROADCAST object:nil];

    self.messageUdpateTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(requestMessageUpdate) userInfo:nil repeats:YES];
    [self.messageTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, 10.0f, 0.f)];
    
    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        id _obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect _keyboardFrame = CGRectNull;
        if ([_obj respondsToSelector:@selector(getValue:)]) [_obj getValue:&_keyboardFrame];
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
			
			
            [self.messageTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, _keyboardFrame.size.height+25.0f, 0.f)];
			[self.messageTable setContentOffset:CGPointMake(0, self.messageTable.contentOffset.y + _keyboardFrame.size.height)];

        } completion:nil];
    }];
    
    self.keyboardRemoveObserver =  [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.messageTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, 10.0f, 0.f)];
            
        } completion:nil];
    }];
    

    [self loadMessageData];
    
    if(self.messages.count > 0) {
        [self.messageTable reloadData];
        NSArray *lastSection = [self.messages lastObject];
        if(lastSection != nil) {
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:lastSection.count-1 inSection:self.messages.count-1];
            [self.messageTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: NO];
        }
    }

    [self.messageTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, 10.0f, 0.f)];

	
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	if(self.messages.count > 0) {
		NSArray *lastSection = [self.messages lastObject];
		if(lastSection != nil) {
			NSIndexPath* ipath = [NSIndexPath indexPathForRow:lastSection.count-1 inSection:self.messages.count-1];
			[self.messageTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: NO];
		}
	}
	
	[super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_BROADCAST object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
     [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardRemoveObserver];
    
    [self.messageUdpateTimer invalidate];
    self.messageUdpateTimer = nil;
    
    [super viewDidDisappear:animated];
}



-(void)updateMessages:(id)sender {
    [self loadMessageData];
    [self.messageTable reloadData];
}

-(void)requestMessageUpdate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate updateLists];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.messages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *messageSection = [self.messages objectAtIndex:section];
    return messageSection.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section = [self.messages objectAtIndex:indexPath.section];
    Message *message = [section objectAtIndex:indexPath.row];
    
	NSLog(message.message);
	
	UIApplication *app = [UIApplication sharedApplication];
	float width = app.keyWindow.bounds.size.width;
	
	NSLog(@"%f",width - 58.0f);
	
    UIFont * font = [UIFont systemFontOfSize:16.0f];
    CGFloat height = [message.message boundingRectWithSize:CGSizeMake(width - 78.0f, 1000.0f) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:nil].size.height;
    
    
    CGFloat finalHeight;
    if(indexPath.row != 0) {
        finalHeight = MAX(height + 12, 39.0f);
    }else {
        finalHeight = MAX(height + 40, 81.0f);
    }
    
    return finalHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *section = [self.messages objectAtIndex:indexPath.section];
    Message *message = [section objectAtIndex:indexPath.row];
    
    NSString *identifier;
    BOOL fullCell = false;

    
    if(indexPath.row==0) {
        fullCell = true;
    }
    
    if(indexPath.section%2==0) {
        if(fullCell) {
             identifier = self.leftCell;
        }
        else {
            identifier = self.leftMessageOnly;
        }
    } else {
        if(fullCell) {
            identifier = self.rightCell;
        }
        else {
            identifier = self.rightMessageOnly;
        }
    }
    
    
    
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.message.text = message.message;
    cell.errorIcon.hidden = YES;
    
    
    if(![message.successful boolValue]) {
        cell.message.textColor = [UIColor grayColor];
    } else {
        cell.message.textColor = [UIColor blackColor];
    }
    
    if([message.failed boolValue]) {
        cell.message.textColor = [UIColor redColor];
        cell.errorIcon.hidden = NO;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorFromHexString:@"#FFF9E0"];
        [cell setSelectedBackgroundView:bgColorView];
    } else {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor clearColor];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    
    
    if(fullCell) {
        if(message.person != nil) {
           // NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.person.pictureURL]];
            //UIImage *img = [[UIImage alloc] initWithData:data];
            //cell.profileImage.image = img;
            

            
            if(message.person.picture != nil) {
                UIImage *image = [UIImage imageWithData:message.person.picture];
                [cell.profileImage setImage:[UIImage scaleAndRotateImage:image]];
            } else {
                NSURL *url = [NSURL URLWithString:message.person.pictureURL];
                [cell.profileImage hnk_setImageFromURL:url];
            }
            
           cell.profileImage.contentMode = UIViewContentModeScaleAspectFill;
            
            cell.nameLabel.text = message.person.name;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm"];
            
            NSString *timeString = [dateFormatter stringFromDate:message.dateTime];
            cell.timeLabel.text = timeString;
            if(message.person.isUser) {
                cell.nameLabel.textColor =[UIColor colorFromHexString:@"#5F5225"];
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.messages objectAtIndex:indexPath.section];
    Message *message = [section objectAtIndex:indexPath.row];
    
    if([message.failed boolValue]) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [message setFailed:[NSNumber numberWithBool:NO]];
        
        [self loadMessageData];
        [self.messageTable reloadData];
        
        [delegate sendMessage:message];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




-(void)keyboardDismiss:(id)sender {
    [self.messageTextField resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

- (UIView *)inputAccessoryView{
    
    return self.sendMessageView;

    
}
- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"quickSegue"]) {
         QuickStatusViewController *vc = [segue destinationViewController];
        vc.event = self.event;
    }
}

-(void)sendText:(NSString *)text {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(delegate.user == nil) return;
    
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [message setEvent:self.event];
    [message setMessage:text];
    [message setPerson:delegate.user];
    [message setDateTime:[NSDate new]];
    [message setFailed:[NSNumber numberWithBool:NO]];
    
    NSError *saveError;
    [delegate saveContext];
    
    [self loadMessageData];
    [self.messageTable reloadData];

    [delegate sendMessage:message];


    NSArray *lastSection = [self.messages lastObject];
    if(lastSection != nil) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:lastSection.count-1 inSection:self.messages.count-1];
        [self.messageTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
}

- (IBAction)sendButtonPressed:(id)sender {
    if(self.messageTextField.text.length>0) {
        [self sendText:self.messageTextField.text];
        [self.messageTextField setText:@""];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(self.messageTextField.text.length>0) {
        [self sendText:self.messageTextField.text];
        [self.messageTextField setText:@""];
        
    }
    return NO;
}

-(void)loadMessageData {

    
    NSArray *messagesFlat = [self.event.messages allObjects];
    
    if(messagesFlat != nil) {
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
     
        messagesFlat = [messagesFlat sortedArrayUsingDescriptors:descriptors];
        
        Person *lastPerson = nil;
        NSMutableArray *messageSection = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:1];
        
        if(messagesFlat.count > 0) {
            for(Message *message in messagesFlat) {

                if(message.person !=lastPerson) {
                    if(messageSection.count > 0) {
                        [sections addObject:[messageSection copy]];
                    }
                    messageSection = [NSMutableArray arrayWithCapacity:1];
                }
                
                [messageSection addObject:message];
                lastPerson = message.person;
            }
            [sections addObject:[messageSection copy]];
            
            self.messages = [sections copy];
        }
        
    } else {
        self.messages = nil;
    }
    
}

@end
