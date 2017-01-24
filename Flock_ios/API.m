//
//  API.m
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "API.h"
#import "UIImage+Resize.h"
#import "ConnectionHandler.h"

#define API_BASE_URL @"https://url.com"
#define API_REGISTER @"pAPI/v1/registration"
#define API_UPDATE_PROFILE @"pAPI/v1/person"
#define API_CREATE_SEED @"sAPI/v1/seed"
#define API_UPDATE_SEED @"sAPI/v1/updateSeeds"
#define API_JOIN_SEED @"sAPI/v1/joinSeed"
#define API_LIST_SEED @"sAPI/v1/listSeeds"
#define API_GET_SEED @"sAPI/v1/getSeed"
#define API_SEND_STATUS @"seedApi/v1/sendStatus"
#define API_UPDATE_LOCATION @"pAPI/v1/updateMyLocation"



@implementation API

+ (id)sharedAPI {
    static API *sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPI = [[self alloc] init];
    });
    return sharedAPI;
}

//TODO: Make method sigs more expressive
-(void)sendRegistration:(UIImage *)image :(NSString *)name completion:(void (^)(APIResponse *response))completionBlock {
    
    if(name == nil) {
        [self replyWithError:@"Could not process name." :INTERNAL_ERROR completion:completionBlock];
         return;
    }
    
    if(image != nil) {
        UIImage *resizedImage = [image resizedImageToFitInSize:CGSizeMake(400, 400) scaleIfSmaller:YES];
       
        if(resizedImage == nil) [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
        
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        
        if(imageData == nil) [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
        
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", imageString, @"photo", nil];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_REGISTER];
        
        ConnectionHandler *handler = [[ConnectionHandler alloc] init];
        [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
        
    } else {
        [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
    }
}

-(void)sendUpdateProfile:(NSString *)personId :(UIImage *)image :(NSString *)name completion:(void (^)(APIResponse *response))completionBlock {
    
    if(personId == nil) {
        [self replyWithError:@"Could not find user." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    if(name == nil) {
        [self replyWithError:@"Could not process name." :INTERNAL_ERROR completion:completionBlock];
         return;
    }
    
    if(image != nil) {
        UIImage *resizedImage = [image resizedImageToFitInSize:CGSizeMake(400, 400) scaleIfSmaller:YES];
        
        if(resizedImage == nil) [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
        
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        
        if(imageData == nil) [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
        
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:personId, @"userId",name, @"name", imageString, @"photo", nil];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_UPDATE_PROFILE];
        
        ConnectionHandler *handler = [[ConnectionHandler alloc] init];
        [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
        
    } else {
        [self replyWithError:@"Could not process image." :INTERNAL_ERROR completion:completionBlock];
    }
}

-(void)sendCreateSeed:(NSDate *)dateTime latitude:(NSNumber *)lat longitude:(NSNumber *)lon personId:(NSString *)personId title:(NSString *)title locationName:(NSString *)locationName isNow:(NSNumber *)isNow completion:(void (^)(APIResponse *response))completionBlock {
    if(personId == nil) {
        [self replyWithError:@"Could not find user." :INTERNAL_ERROR completion:completionBlock];
        return;
    }

    if(dateTime == nil && [isNow intValue] != 1) {
        [self replyWithError:@"Could not process date." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    NSNumber *dateTimeNum = [NSNumber numberWithInt:0];
    
    if(dateTime != nil) {
        dateTimeNum = [NSNumber numberWithDouble:[dateTime timeIntervalSince1970]];
    }
    
    NSDictionary *latlong = [NSDictionary dictionaryWithObjectsAndKeys:lat, @"latitude", lon, @"longitude", nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:latlong, @"location", personId,@"userId", title, @"title", locationName, @"locationName", isNow, @"isNow",dateTimeNum, @"datetime", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CREATE_SEED];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
}

-(void)sendUpdateSeed:(NSString *)seedId datetime:(NSDate *)dateTime latitude:(NSNumber *)lat longitude:(NSNumber *)lon personId:(NSString *)personId title:(NSString *)title locationName:(NSString *)locationName isNow:(NSNumber *)isNow completion:(void (^)(APIResponse *response))completionBlock {
    if(personId == nil) {
        [self replyWithError:@"Could not find user." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    if(seedId == nil) {
        [self replyWithError:@"Could not send." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    if(dateTime == nil && [isNow intValue] != 1) {
        [self replyWithError:@"Could not process date." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    NSNumber *dateTimeNum = [NSNumber numberWithInt:0];
    
    if(dateTime != nil) {
        dateTimeNum = [NSNumber numberWithDouble:[dateTime timeIntervalSince1970]];
    }
    
    NSDictionary *latlong = [NSDictionary dictionaryWithObjectsAndKeys:lat, @"latitude", lon, @"longitude", nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:locationName, @"locationName", seedId, @"id", latlong, @"location", personId,@"userId", title, @"title", isNow, @"isNow",dateTimeNum, @"datetime", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_UPDATE_SEED];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];

}

-(void)sendUpdateLocationForUserId:(NSString *)userId lat:(NSNumber *)lat lon:(NSNumber *)lon heading:(NSNumber *)heading seeds:(NSArray *)events completion:(void (^)(APIResponse *response))completionBlock {
    if(userId == nil) {
        [self replyWithError:@"Could not find user." :INTERNAL_ERROR completion:completionBlock];
        return;
    }

    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:lat, @"latitude", lon, @"longitude", heading, @"heading", nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", location, @"location", events, @"seedList", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_UPDATE_LOCATION];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
}

-(void)sendStatus:(NSString *)userId withSeedID:(NSString *)seedId withMessage:(NSString *)message completion:(void (^)(APIResponse *response))completionBlock {
 
    if(userId == nil) {
        [self replyWithError:@"Could not connect." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    if(seedId == nil) {
        [self replyWithError:@"Could not send." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", seedId, @"seedId", message,@"message",  nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_SEND_STATUS];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
}

-(void)sendJoinSeedWithUserId:(NSString *)userId withSeedID:(NSString *)seedId completion:(void (^)(APIResponse *response))completionBlock {
    
    if(userId == nil) {
        [self replyWithError:@"Could not find user." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    if(seedId == nil) {
        [self replyWithError:@"Could not send." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", seedId, @"seedId", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_JOIN_SEED];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
    
}

-(void)sendGetSeedsForUserId:(NSString *)userId lastUpdate:(NSNumber *)lastUpdate completion:(void (^)(APIResponse *response))completionBlock {
    if(userId == nil) {
        [self replyWithError:@"Could not connect." :INTERNAL_ERROR completion:completionBlock];
        return;
    }

    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", lastUpdate, @"datetime", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_LIST_SEED];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
}

-(void)sendGetSeedData:(NSString *)seedLink completion:(void (^)(APIResponse *response))completionBlock {
    
    
    if(seedLink == nil) {
        [self replyWithError:@"Could not connect." :INTERNAL_ERROR completion:completionBlock];
        return;
    }
    
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:seedLink, @"url", nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_GET_SEED];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    [handler sendPostRequestToAddress:urlString withData:dictionary withCompletionHandler:completionBlock];
}

-(void)replyWithError:(NSString *)error :(int)code completion:(void (^)(APIResponse *response))completionBlock{
    APIResponse *response = [[APIResponse alloc] init];
    response.code = code;
    response.comment = NSLocalizedString(error, nil);
    
    completionBlock(response);
}

@end
