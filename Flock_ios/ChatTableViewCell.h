//
//  ChatTableViewCell.h
//  Mustard
//
//  Created by Eric Schmitt on 4/10/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Haneke.h"
#import "UIImageView+Haneke.h"

@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property BOOL isLeft;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;

@end
