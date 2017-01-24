//
//  ListViewController.h
//  Flock_ios
//
//  Created by Eric Schmitt on 4/7/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MustardViewController.h"
#import "AppDelegate.h"
#import "EventCell.h"

@interface ListViewController : MustardViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *events;
@property (weak, nonatomic) IBOutlet UIView *noSeedsOverlay;
@property (weak, nonatomic) IBOutlet UIButton *unjoinedSeedsButton;
@property (weak, nonatomic) IBOutlet UIView *unjoinedCount;
@property (weak, nonatomic) IBOutlet UILabel *unjoinedCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *eventList;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) EventCell *selectedEventCell;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;

- (IBAction)joinShort:(id)sender;

@end
