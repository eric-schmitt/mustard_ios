//
//  AddPersonPhoneNumberCell.h
//  Mustard
//
//  Created by Eric Schmitt on 4/16/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPersonTableViewCell.h"
#import "ContactDetail.h"

@interface AddPersonPhoneNumberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) AddPersonTableViewCell *parent;
@property (strong, nonatomic) ContactDetail *contactDetail;

@end
