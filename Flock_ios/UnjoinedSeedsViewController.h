//
//  UnjoinedSeedsViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/28/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MustardViewController.h"
#import "AppDelegate.h"

@interface UnjoinedSeedsViewController : MustardViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *unjoinedDetailLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property (weak, nonatomic) IBOutlet UILabel *pageItle;

@property NSArray *events;
- (IBAction)backPressed:(id)sender;

@end
