//
//  QuickStatusViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"
#import "Event.h"
#import "MustardViewController.h"

@interface QuickStatusViewController : MustardViewController <UITableViewDelegate, UITableViewDataSource>
@property NSArray *quickStatus;
@property (weak, nonatomic) IBOutlet UILabel *quickDetailLabel;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;

@property Event *event;
@end
