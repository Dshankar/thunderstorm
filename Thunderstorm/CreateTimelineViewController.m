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
    NSString *timelineId;
    PublishViewController *publish;
}
@end

@implementation CreateTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    

    [self createTimeline];
}

-(void)createTimeline
{
    Settings *settings = [Settings getInstance];
    timelineId = nil;
    
    NSString *timelineTitle = ((CreateTimelineTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).titleField.text;
    
    NSURL *createTimelineURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/beta/timelines/custom/create.json"];
    NSDictionary *createTimelineParams = @{
                                           @"name":timelineTitle,
                                           @"include_entities":@"1",
                                           @"include_user_entities":@"1",
                                           @"include_cards":@"1",
                                           @"send_error_codes":@"1"
                                           };
    
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:createTimelineURL parameters:createTimelineParams];
    
    [req setAccount:settings.account];
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(responseData){
            NSLog(@"Created Custom Timeline HTTP res: %li", (long)urlResponse.statusCode);
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
//            NSLog(@"%@", response);
            
            timelineId = [[response objectForKey:@"response"] objectForKey:@"timeline_id"];
            [publish beginPublishingTweets:tweets onTimeline:timelineId];
        }
    }];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
