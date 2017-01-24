//
//  MustardViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 5/19/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "MustardViewController.h"
#import "UIColor+HexString.h"

@interface MustardViewController ()

@end

@implementation MustardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startLoadingScreen {
    self.loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    background.backgroundColor = [UIColor colorFromHexString:@"#000000"];
    background.alpha = 0.8f;
    background.layer.cornerRadius = 3.0f;
    
    [self.loadingView addSubview:background];
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0f - 50.0f, self.view.bounds.size.height/2.0f - 50.0f, 100, 100)];
    view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    view.color = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0f - 100.0f, self.view.bounds.size.height/2.0f + 30.0f, 200.0f, 50.0f)];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:NSLocalizedString(@"Working...", nil)];
    
    [self.loadingView addSubview:view];
    [self.loadingView addSubview:label];
    
    [view startAnimating];
    
    [self.view addSubview:self.loadingView];
}

-(void)stopLoadingScreen {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

-(void)setTrackingValue:(NSString *)name {
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:name];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
