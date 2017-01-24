//
//  IntroPageViewViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "IntroPageViewViewController.h"

@interface IntroPageViewViewController ()

@end

@implementation IntroPageViewViewController

-(instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    
    return [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:navigationOrientation options:options];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    UIViewController *page1 = [self.storyboard instantiateViewControllerWithIdentifier:@"page1"];
    UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"page2"];
	UIViewController *page3 = [self.storyboard instantiateViewControllerWithIdentifier:@"page3"];
	UIViewController *page4 = [self.storyboard instantiateViewControllerWithIdentifier:@"page4"];
	UIViewController *page5 = [self.storyboard instantiateViewControllerWithIdentifier:@"page5"];
    
    self.pages = @[page1, page2, page3, page4, page5];
    
    [self setViewControllers:@[page1] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];
    NSUInteger previousIndex = (currentIndex+1)%self.pages.count;
    return self.pages[previousIndex];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];
    NSUInteger previousIndex = (currentIndex-1)%self.pages.count;
    return self.pages[previousIndex];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.pages.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
