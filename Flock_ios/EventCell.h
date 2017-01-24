//
//  EventCell.h
//  Flock_ios
//
//  Created by Eric Schmitt on 4/7/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *when;
@property (strong, nonatomic) Event *event;

@end
