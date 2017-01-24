//
//  AddPersonTableViewCell.h
//  Mustard
//
//  Created by Eric Schmitt on 4/15/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInList.h"

@interface AddPersonTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *personName;
@property BOOL personIncluded;
@property (weak, nonatomic) PersonInList *originalItem;
@property (strong, nonatomic) NSMutableArray *childrenCells;
@property BOOL isOpen;

@end
