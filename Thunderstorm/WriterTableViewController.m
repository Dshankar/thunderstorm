//
//  WriterTableViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterTableViewController.h"
#import "WriterTableViewCell.h"
#import "UIColor+ThunderColors.h"

@interface WriterTableViewController ()
@end

@implementation WriterTableViewController
{
    UIBarButtonItem* _publishButton;
    NSString* _DEFAULT_TWEET_PROMPT;
}
@synthesize tweetData;
@synthesize tweetNumberOfLines;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _DEFAULT_TWEET_PROMPT = @"What's on your mind?";
        
        _publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        [_publishButton setTintColor:[UIColor linkBlue]];
        
        UIFontDescriptor* fontDescriptor = [UIFontDescriptor
                                            preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        UIFontDescriptor* boldFontDescriptor = [fontDescriptor
                                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont* boldFont =  [UIFont fontWithDescriptor:boldFontDescriptor size: 0.0];
        NSDictionary *boldAttribute = @{NSFontAttributeName : boldFont};
        [_publishButton setTitleTextAttributes:boldAttribute forState:UIControlStateNormal];
        
        // for settings use @"\u2699"
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(displaySettings:)];
        [settingsButton setTintColor:[UIColor mutedGray]];
        
// For future reference
// This will one day be a deeper view in the nav stack, preceded by a setup view
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//        [self.navigationItem setLeftBarButtonItem:backButton];
        
        [self.navigationItem setLeftBarButtonItem:settingsButton];
        [self.navigationItem setRightBarButtonItem:_publishButton];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 165;
    self.tweetData = [[NSMutableArray alloc] initWithObjects:_DEFAULT_TWEET_PROMPT, nil];

    self.tweetNumberOfLines = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)longPressGestureRecognized:(id)sender
{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot= nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch(state){
        case UIGestureRecognizerStateBegan: {
            if(indexPath){
                sourceIndexPath = indexPath;
                
                WriterTableViewCell *cell = (WriterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                snapshot = [self customSnapshotFromView:cell];
                
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.backgroundColor = [UIColor colorWithRed:(238.0/255) green:(238.0/255) blue:(238.0/255) alpha:1.0];
                    cell.textView.hidden = YES;
                    cell.tweetId.hidden = YES;
                    
                } completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            if(indexPath && ![indexPath isEqual:sourceIndexPath]){
                [self.tweetData exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [self.tweetNumberOfLines exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            WriterTableViewCell *cell = (WriterTableViewCell *)[self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                cell.backgroundColor = [UIColor whiteColor];
                cell.textView.hidden = NO;
                cell.tweetId.hidden = NO;
                
            } completion:^(BOOL finished){
                [snapshot removeFromSuperview];
                snapshot = nil;
                
                [self.tableView beginUpdates];
                [self.tableView reloadData];
                [self.tableView endUpdates];
            }];
            sourceIndexPath = nil;
            break;
        }
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
        cell.textView.tag = indexPath.row;
        cell.textView.delegate = self;
        
        
        UIView *inputAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        inputAccessory.backgroundColor = [UIColor whiteColor];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1.0)];
        UIColor *ultraLightGray = [UIColor colorWithRed:(232.0/255) green:(236.0/255) blue:(240.0/255) alpha:1.0];
        seperator.backgroundColor = ultraLightGray;
        [inputAccessory addSubview:seperator];
        
        UIButton *newCellButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        newCellButton.frame = CGRectMake(160, 0, 160, 44);
        [newCellButton setTitle:@"+" forState:UIControlStateNormal];
        [newCellButton.titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [newCellButton setTitleColor:[UIColor linkBlue] forState:UIControlStateNormal];
        [newCellButton addTarget:self action:@selector(addNewCell:) forControlEvents:UIControlEventTouchUpInside];
        [inputAccessory addSubview:newCellButton];

        cell.textView.inputAccessoryView = inputAccessory;
        
        
    }
    
    [cell.textView setText:[self.tweetData objectAtIndex:indexPath.row]];
    [cell.tweetId setText:[NSString stringWithFormat:@"%d/", indexPath.row + 1]];
    
    return cell;
}

- (void)addNewCell:(id)sender
{
    [self.tweetData addObject:_DEFAULT_TWEET_PROMPT];
    [self.tweetNumberOfLines addObject:[NSNumber numberWithInt:1]];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:tweetData.count - 1 inSection:0]];
    [self.tableView beginUpdates];
    [[self tableView] insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tweetData.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    UIResponder *nextResponder = [self.tableView viewWithTag:tweetData.count - 1];
    [nextResponder becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *numLines = [tweetNumberOfLines objectAtIndex:indexPath.row];
    if(numLines.intValue == 1){
            return (25.839844 + 50);
    } else {
            return (25.839844 * numLines.intValue) + 50;
    }
}

- (void) textViewDidBeginEditing:(UITextView *) tv {
    if([tv.text isEqualToString:_DEFAULT_TWEET_PROMPT]){
        [tv setText:@""];
    }
}

- (void)textViewDidChange:(UITextView *)tv
{
    [tweetData setObject:tv.text atIndexedSubscript:tv.tag];
    
    int calcNumberOfLines = (tv.contentSize.height / tv.font.lineHeight);
    NSNumber *prevNumberOfLines = [tweetNumberOfLines objectAtIndex:tv.tag];
    
    if(calcNumberOfLines != prevNumberOfLines.intValue){
        [tweetNumberOfLines setObject:[NSNumber numberWithInt:calcNumberOfLines] atIndexedSubscript:tv.tag];
        CGRect tvFrame = [tv frame];
        tvFrame.size.height = tv.contentSize.height;
        [tv setFrame:tvFrame];
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tv.tag inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    NSLog(@"%d", calcNumberOfLines);
//    }
}

//from http://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
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
