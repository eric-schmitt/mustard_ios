//
//  IntroPageViewViewController.h
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPageViewViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property NSArray *pages;

@end
