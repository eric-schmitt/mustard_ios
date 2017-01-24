//
//  MustardViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>

@interface MustardViewController : UIViewController

@property (strong, nonatomic) UIView *loadingView;

-(void)startLoadingScreen;
-(void)stopLoadingScreen;
-(void)setTrackingValue:(NSString *)name;

@end
