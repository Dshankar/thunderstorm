//
//  CreateTimelineViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/9/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "CreateTimelineViewController.h"
#import "CreateTimelineTableViewCell.h"
#import "PublishViewController.h"
#import <Social/Social.h>
#import "Settings.h"

@interface CreateTimelineViewController (){
    NSArray *tweets;
    PublishViewController *publish;
}
@end

@implementation CreateTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.navigationItem.backBarButtonItem setAction:@selector(backtoWriterController:)];
        
        UIBarButtonItem *publishButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"publish.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        [self.navigationItem setRightBarButtonItem:publishButton];

    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style Tweets:(NSArray *)tweetData
{
    tweets = tweetData;
    return [self initWithStyle:style];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)publishTweets:(id)sender
{
    publish = [[PublishViewController alloc] initWithNibName:nil bundle:nil];
    publish.view.backgroundColor = [UIColor colorWithRed:45.0/255 green:48.0/255 blue:54.0/255 alpha:0.95];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:publish animated:NO completion:nil];
    //    [self.navigationController pushViewController:publish animated:YES];

    publish.view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
         publish.view.alpha = 1;
    }];

    self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;

    NSString *timelineTitle = ((CreateTimelineTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).titleField.text;
    NSString *timelineDescription = ((CreateTimelineTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).titleField.text;
    
    [publish beginPublishingTweets:tweets onTimeline:timelineTitle Description:timelineDescription];
}

- (void)backtoWriterController:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateTimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimelineCell"];
    if(cell == nil){
        cell = [[CreateTimelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimelineCell"];
    }
    if(indexPath.row == 0){
        [cell.titleField setPlaceholder:@"Tweetstorm Title"];
        [cell.titleField becomeFirstResponder];
    } else if(indexPath.row == 1){
        [cell.titleField setPlaceholder:@"Description"];
    }
    

    return cell;
}
@end
