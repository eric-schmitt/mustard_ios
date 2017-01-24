//
//  ChatTableViewCell.m
//  Mustard
//
//  Created by Eric Schmitt on 4/10/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profileImage.layer.cornerRadius = 21;
    self.profileImage.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
