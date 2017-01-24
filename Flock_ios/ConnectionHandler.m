//
//  ConnectionHandler.m
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "ConnectionHandler.h"



@implementation ConnectionHandler

-(void)sendPostRequestToAddress:(NSString *)address withData:(NSDictionary *)data withCompletionHandler:(CompletionBlock)completionBlock {
    
    self.completionBlock = completionBlock;
    self.errorCount = 0;
    
    self.responseData = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
   [request setHTTPMethod:@"POST"];
               
   [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    request.HTTPBody = jsonData;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    self.code = [httpResponse statusCode];

}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    APIResponse *responseObj = [[APIResponse alloc] init];
    responseObj.code = self.code;
    NSString *dataString =  [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    responseObj.body = dataString;
    
    NSError *error;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                       options:kNilOptions
                                                                         error:&error];
    
    if (responseDictionary != nil)
    {
        responseObj.responseDictionary = responseDictionary;
    }
    
    if (self.code == 404)
    {
        responseObj.comment = NSLocalizedString(@"Could not connect. Please check your internet.", nil);
    } else if(self.code != 200 && self.code != 204) {
        responseObj.comment = NSLocalizedString(@"Could not connect.", nil);
    }
    
    if(self.completionBlock != nil)
        self.completionBlock(responseObj);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.errorCount++;
    
    if(self.errorCount < 3) [connection start];
    else {
        APIResponse *response = [[APIResponse alloc] init];
        response.code = 500;
        response.body = @"";
        response.comment = NSLocalizedString(@"Could not connect. Please check your internet.", nil);
        self.completionBlock(response);
    }
    
}

@end
