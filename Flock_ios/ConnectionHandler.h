//
//  ConnectionHandler.h
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIResponse.h"

typedef void  (^CompletionBlock)(APIResponse*);

@interface ConnectionHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property NSMutableData *responseData;
@property NSInteger code;
@property int errorCount;
@property CompletionBlock completionBlock;

-(void)sendPostRequestToAddress:(NSString *)address withData:(NSDictionary *)data withCompletionHandler:(CompletionBlock)completionBlock;

@end
