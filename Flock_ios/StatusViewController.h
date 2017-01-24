//
//  StatusViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/10/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Person.h"
#import "Message.h"
#import "ChatTableViewCell.h"
#import "MustardViewController.h"

@interface StatusViewController : MustardViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (weak, nonatomic) IBOutlet UIView *sendMessageView;


- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonPressed;
@property (weak, nonatomic) IBOutlet UIButton *quickButtonPressed;

@property (strong, nonatomic) Event *event;
@property BOOL lastCellLeft;

@property (strong, nonatomic) NSString *leftCell;
@property (strong, nonatomic) NSString *rightCell;
@property (strong, nonatomic) NSString *leftMessageOnly;
@property (strong, nonatomic) NSString *rightMessageOnly;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSTimer *messageUdpateTimer;
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;

@property id keyboardShowObserver;
@property id keyboardRemoveObserver;

-(void)sendText:(NSString *)text;
- (IBAction)sendButtonPressed:(id)sender;

@end
