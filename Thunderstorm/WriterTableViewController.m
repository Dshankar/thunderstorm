//
//  WriterTableViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterTableViewController.h"
#import "WriterTableViewCell.h"

@interface WriterTableViewController ()
@end

@implementation WriterTableViewController
{
    UIBarButtonItem* _publishButton;
}
@synthesize tweetData;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        [_publishButton setTintColor:[UIColor grayColor]];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(displaySettings:)];
        [settingsButton setTintColor:[UIColor grayColor]];
        
        [self.navigationItem setLeftBarButtonItem:settingsButton];
        [self.navigationItem setRightBarButtonItem:_publishButton];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 165;
    self.tweetData = [[NSArray alloc] initWithObjects:@"Why print out pages of unreadable stacktraces that are useless to most programmers? Memory addresses don't help me debug such errors.", @"What's on your mind?", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) publishTweets:(id)sender
{
    
}

- (void) displaySettings:(id)sender
{
    
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
    return [self.tweetData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    WriterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[WriterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textView setText:[self.tweetData objectAtIndex:indexPath.row]];
    [cell.tweetId setText:[NSString stringWithFormat:@"%d/", indexPath.row + 1]];
    
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
