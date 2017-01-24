//
//  StartTrackingTableViewCell.m
//  Mustard
//
//  Created by Eric Schmitt on 4/18/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "StartTrackingTableViewCell.h"

@implementation StartTrackingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
