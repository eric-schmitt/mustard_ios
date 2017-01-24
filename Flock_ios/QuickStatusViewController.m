//
//  QuickStatusViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/21/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "QuickStatusViewController.h"
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "Message.h"

@interface QuickStatusViewController ()

@end

@implementation QuickStatusViewController



- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    self.quickStatus = [NSArray arrayWithObjects:
                        NSLocalizedString(@"I'm leaving now.", nil),
                        NSLocalizedString(@"I'll be late.", nil),
                        NSLocalizedString(@"I'll be there in 5 mintues", nil),
                        NSLocalizedString(@"Got a table.", nil),
                        NSLocalizedString(@"I'm not going to make it.", nil)
                        , nil];
    
    self.quickDetailLabel.text = NSLocalizedString(@"Tap to send a quick status update.", nil);
    
    self.statusTitle.text = self.event.title;
	
	[self setTrackingValue:@"Quick Status"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.quickStatus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    
    NSString *item = [self.quickStatus objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item;

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorFromHexString:@"#FFF9E0"];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [self.quickStatus objectAtIndex:indexPath.row];
    [self sendText:text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendText:(NSString *)text {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(delegate.user == nil) return;
    
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [message setEvent:self.event];
    [message setMessage:text];
    [message setPerson:delegate.user];
    [message setDateTime:[NSDate new]];

    NSError *saveError;
    [delegate saveContext];
    
    [delegate sendMessage:message];
    
}

@end
