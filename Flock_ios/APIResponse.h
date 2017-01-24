//
//  APIResponse.h
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIResponse : NSObject


@property NSInteger code;
@property NSString *body;
@property NSDictionary *responseDictionary;
@property NSString *comment;

@end
