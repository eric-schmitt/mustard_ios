//
//  API.h
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//
#define INTERNAL_ERROR 1001
#define NOT_FOUND_ERROR 404

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APIResponse.h"

@interface API : NSObject

+ (id)sharedAPI;

-(void)sendRegistration:(UIImage *)image :(NSString *)name completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendUpdateProfile:(NSString *)personId :(UIImage *)image :(NSString *)name completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendCreateSeed:(NSDate *)dateTime latitude:(NSNumber *)lat longitude:(NSNumber *)lon personId:(NSString *)personId title:(NSString *)title locationName:(NSString *)locationName isNow:(NSNumber *)isNow completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendUpdateSeed:(NSString *)seedId datetime:(NSDate *)dateTime latitude:(NSNumber *)lat longitude:(NSNumber *)lon personId:(NSString *)personId title:(NSString *)title locationName:(NSString *)locationName isNow:(NSNumber *)isNow completion:(void (^)(APIResponse *response))completionBlock;


-(void)sendUpdateLocationForUserId:(NSString *)userId lat:(NSNumber *)lat lon:(NSNumber *)lon heading:(NSNumber *)heading seeds:(NSArray *)events completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendStatus:(NSString *)userId withSeedID:(NSString *)seedId withMessage:(NSString *)message completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendJoinSeedWithUserId:(NSString *)userId withSeedID:(NSString *)seedId completion:(void (^)(APIResponse *response))completionBlock;

-(void)sendGetSeedsForUserId:(NSString *)userId lastUpdate:(NSNumber *)lastUpdate completion:(void (^)(APIResponse *response))completionBlock ;

-(void)sendGetSeedData:(NSString *)seedLink completion:(void (^)(APIResponse *response))completionBlock;

@end
