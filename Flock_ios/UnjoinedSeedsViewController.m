//
//  UnjoinedSeedsViewController.m
//  Mustard
//
//  Created by Eric Schmitt on 4/28/16.
//  Copyright © 2016 Eric Schmitt. All rights reserved.
//

#import "UnjoinedSeedsViewController.h"
#import "Event.h"
#import "EventCell.h"
#import "JoinSeedViewController.h"
#import "NSDate+WT.h"

@interface UnjoinedSeedsViewController ()

@end

@implementation UnjoinedSeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageItle.text = NSLocalizedString(@"Seeds", nil);
}

-(void)viewWillAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    self.unjoinedDetailLabel.text = NSLocalizedString(@"Seeds you haven't joined yet.", nil);
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"isFinished != YES && hasJoined == NO && datetime >= %@",  [[NSDate new] dateByAddingTimeInterval:-EVENT_TIMEOUT]];
    NSError *error;
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if(result != nil) {
        self.events = result;
    }
    
    [super viewWillAppear:animated];
	
	[self setTrackingValue:@"Unjoined Seed List"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    if (!cell) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"eventCell"];
    }
    
    Event *event = [self.events objectAtIndex:indexPath.row];
    
    cell.title.text = event.title;
    
    NSString *dateString;
    
    if([event.datetime isToday]) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        dateString = [NSString stringWithFormat:NSLocalizedString(@"Today @ %@", nil), timeString];
    } else if([event.datetime isTomorrow]) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:event.datetime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        dateString = [NSString stringWithFormat:NSLocalizedString(@"Tomorrow @ %@", nil), timeString];
    } else {
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *dateComponents = @"EEEEMMMMd h:mm a";
        
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocale];
        
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        
        dateString = [dateFormatter stringFromDate:event.datetime];
    }

    
    cell.when.text = dateString;
    cell.event = event;
    
    
    
    return cell;
}


-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            Event *event = [self.events objectAtIndex:indexPath.row];
                                            NSMutableArray *mutableEvents = [self.events mutableCopy];
                                            [mutableEvents removeObject:event];
                                            self.events = [mutableEvents copy];
                                            
                                            [self.tableView beginUpdates];
                                            [self.tableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationTop];
                                            [self.tableView endUpdates];
                                            
                                            
                                            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                            [delegate.managedObjectContext deleteObject:event];
                                            [delegate saveContext];
                                        });
                                    }];
    button.backgroundColor = [UIColor redColor];
    
    return @[button];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"unjoinedToJoinSegue"])
    {
        // Get reference to the destination view controller
        JoinSeedViewController *vc = [segue destinationViewController];
        
        EventCell *cell = (EventCell*)sender;
        Event *event = cell.event;
        vc.needsRequest = NO;
        vc.event = event;
        
    } else if ([[segue identifier] isEqualToString:@"JoinSeed"]) {
        JoinSeedViewController *seedVC = [segue destinationViewController];
        seedVC.event = [self.events objectAtIndex:0];
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
