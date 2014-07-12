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
#import "PublishViewController.h"
#import "SettingsTableViewController.h"
#import "CreateTimelineViewController.h"

@interface WriterTableViewController ()
@end

@implementation WriterTableViewController
{
    UIBarButtonItem* _publishButton;
    NSString* _DEFAULT_TWEET_PROMPT;
    UIResponder* currentlyEditing;
    BOOL isViewingWriterController;
}
@synthesize tweetData;
@synthesize tweetNumberOfLines;
@synthesize tableView;
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _DEFAULT_TWEET_PROMPT = @"What's on your mind?";
        isViewingWriterController = YES;
        
//        _publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
//        UIFont* boldFont =  [UIFont fontWithName:@"Lato-Bold" size:19.0f];
//        NSDictionary *mainFontAttributes = @{NSFontAttributeName : boldFont, NSForegroundColorAttributeName : [UIColor whiteColor]};
//        [_publishButton setTitleTextAttributes:mainFontAttributes forState:UIControlStateNormal];
//        _publishButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"publish.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        
//        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(displaySettings:)];
//        [self.navigationItem setLeftBarButtonItem:settingsButton];
//        [self.navigationItem setRightBarButtonItem:_publishButton];
        
    }
    return self;
}
 */

- (id)init
{
    self = [super init];
    if(self){
        _DEFAULT_TWEET_PROMPT = @"What's on your mind?";
        isViewingWriterController = YES;
        
        UIImage *publishImage = [UIImage imageNamed:@"publish.png"];
        UIButton *publish = [UIButton buttonWithType:UIButtonTypeCustom];
        [publish setFrame:CGRectMake(236.0, 20.0, 64.0, 30.0)];
        [publish setBackgroundImage:publishImage forState:UIControlStateNormal];
        [self.view addSubview:publish];
        
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 20.0, 206.0, 30.0)];
        [tf setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        [tf setPlaceholder:@"Title"];
        [self.view addSubview:tf];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60.0, 320.0, 508.0) style:UITableViewStylePlain];
//        self.tableView.delegate = self;
//        self.tableView.dataSource = self;
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self.tableView addGestureRecognizer:longPress];
        
        [self.view addSubview:self.tableView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isViewingWriterController = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
//    [self.tableView setDelegate:self];
//    [self.tableView setDataSource:self];
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
//    self.tableView.rowHeight = 165;
//    self.tweetData = [[NSMutableArray alloc] initWithObjects:_DEFAULT_TWEET_PROMPT, nil];
    
    self.tweetData = [[NSMutableArray alloc] initWithObjects:@"Call me Ishmael.", @"Some years ago--never mind how long precisely--having little or no money in my purse, and nothing particular to interest me on shore,", @"I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating", @"the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find", @"myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever", nil];

//    self.tweetNumberOfLines = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], nil];

    self.tweetNumberOfLines = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:4], [NSNumber numberWithInt:4], [NSNumber numberWithInt:4], [NSNumber numberWithInt:4], nil];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    [self.tableView addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                    cell.backgroundColor = [UIColor colorWithRed:(28.0/255) green:(28.0/255) blue:(28.0/255) alpha:1.0];
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
    CreateTimelineViewController *create = [[CreateTimelineViewController alloc] initWithStyle:UITableViewStyleGrouped Tweets:tweetData];
    [self.navigationController pushViewController:create animated:YES];
    isViewingWriterController = NO;
}

- (void) displaySettings:(id)sender
{
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:settingsNav animated:YES completion:nil];
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
        cell.textView.delegate = self;
        
        UIView *inputAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        inputAccessory.backgroundColor = [UIColor whiteColor];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1.0)];
        UIColor *ultraLightGray = [UIColor colorWithRed:(232.0/255) green:(236.0/255) blue:(240.0/255) alpha:1.0];
        seperator.backgroundColor = ultraLightGray;
        [inputAccessory addSubview:seperator];
        
        UIButton *newCellButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        newCellButton.frame = CGRectMake(210, 0, 100, 44);
        UIImageView *newCellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 11, 20, 20)];
        [newCellImageView setImage:[UIImage imageNamed:@"new.png"]];
        [newCellButton addSubview:newCellImageView];
        [newCellButton addTarget:self action:@selector(addNewCell:) forControlEvents:UIControlEventTouchUpInside];
        [inputAccessory addSubview:newCellButton];
        
        UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        hideKeyboardButton.frame = CGRectMake(110, 0, 100, 44);
        UIImageView *hideKeyboardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 11, 20, 20)];
        [hideKeyboardImageView setImage:[UIImage imageNamed:@"keyboard.png"]];
        [hideKeyboardButton addSubview:hideKeyboardImageView];
        [hideKeyboardButton addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [inputAccessory addSubview:hideKeyboardButton];
        
        UIButton *deleteAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteAllButton.frame = CGRectMake(10, 0, 100, 44);
        UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 11, 20, 20)];
        [deleteImageView setImage:[UIImage imageNamed:@"trash.png"]];
        [deleteAllButton addSubview:deleteImageView];
        [deleteAllButton addTarget:self action:@selector(deleteAllTweets:) forControlEvents:UIControlEventTouchUpInside];
        [inputAccessory addSubview:deleteAllButton];

        cell.textView.inputAccessoryView = inputAccessory;
    }
    
    [cell.textView setText:[self.tweetData objectAtIndex:indexPath.row]];
    [cell.tweetId setText:[NSString stringWithFormat:@"%d/", indexPath.row + 1]];
    if(indexPath.row + 1 >= 10){
        [cell.tweetId setFrame:CGRectMake(4, 4, 30, 16)];
        UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,30,16)];
        cell.textView.textContainer.exclusionPaths = @[exclusionPath];
    } else {
        [cell.tweetId setFrame:CGRectMake(4, 4, 20, 16)];
        UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,20,16)];
        cell.textView.textContainer.exclusionPaths = @[exclusionPath];
    }
    
    CGRect tvFrame = [cell.textView frame];
    float lineHeight = cell.textView.font.lineHeight + 3;
    tvFrame.size.height = ([(NSNumber *)[self.tweetNumberOfLines objectAtIndex:indexPath.row] intValue] * lineHeight) + 8;
    [cell.textView setFrame:tvFrame];
    
    cell.textView.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *numLines = [tweetNumberOfLines objectAtIndex:indexPath.row];
    float lineHeight = [UIFont fontWithName:@"Lato-Regular" size:16.0f].lineHeight + 3;
    return (lineHeight * numLines.intValue) + 20 + 8;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){

        BOOL deleteCurrentlyEditing = NO;
        BOOL deleteCurrentlyEditingLastTweet = NO;
        
        [currentlyEditing resignFirstResponder];
        
        // does user want to delete a line that the user is currently editing?
        if([(UITextView *)currentlyEditing tag] == indexPath.row){
            currentlyEditing = nil;
            deleteCurrentlyEditing = YES;

            // make sure user is not deleting the last tweet
            if(tweetData.count > indexPath.row + 1){
                deleteCurrentlyEditingLastTweet = NO;
            } else {
                deleteCurrentlyEditingLastTweet = YES;
            }
        }
        
        [tweetData removeObjectAtIndex:indexPath.row];
        [tweetNumberOfLines removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(tweetData.count == 0){
            [self addNewCell:nil];
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadData];
        [self.tableView endUpdates];
        
        if(deleteCurrentlyEditing){
            // user deleted the currently editing cell
            WriterTableViewCell *cell;
            
            if(deleteCurrentlyEditingLastTweet){
                // user deleted last tweet, so set responder to previous element
                // as long as this isn't the only tweet
                if(tweetData.count > 1){
                    cell = (WriterTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row-1) inSection:0]];
                } else {
                    // user deleted the only tweet
                    cell = (WriterTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                }
            } else {
                // user did not delete the last tweet, so set responder to next element
                // the indexPath now refers to the "next element" because the cell previously in this indexPath is already deleted
                cell = (WriterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            }
            [cell.textView becomeFirstResponder];
            currentlyEditing = cell.textView;
            
        } else {
            // bring back the keyboard to whichever cell was currently being edited
            // wait until UITableViewRowAnimationFade is complete
            [self performSelector:@selector(reassignResponder) withObject:nil afterDelay:0.2];
        }

    }
}

- (void)reassignResponder
{
    [currentlyEditing becomeFirstResponder];
}

- (void)deleteAllTweets:(id)sender
{
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Delete All?" message:@"Tip: You can swipe left to delete individual tweets" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete All", nil];
    [confirm show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        if(currentlyEditing){
            [currentlyEditing resignFirstResponder];
        }
        
        [tweetData removeAllObjects];
        [tweetNumberOfLines removeAllObjects];
        [tweetData addObject:@""];
        [tweetNumberOfLines addObject:[NSNumber numberWithInt:1]];
        [self.tableView reloadData];
        
        WriterTableViewCell *cell = (WriterTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        currentlyEditing = cell.textView;
        [currentlyEditing becomeFirstResponder];
    }
}

- (void)hideKeyboard:(id)sender
{
    if(isViewingWriterController){
        if(currentlyEditing){
            [currentlyEditing resignFirstResponder];
            currentlyEditing = nil;
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)addNewCell:(id)sender
{
    [self.tweetData addObject:@""];
    [self.tweetNumberOfLines addObject:[NSNumber numberWithInt:1]];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:tweetData.count - 1 inSection:0];
    NSArray *paths = [NSArray arrayWithObject:path];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    WriterTableViewCell *cell = (WriterTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
    UITextView *tv = cell.textView;
    
    UIResponder *nextResponder = tv;
    if(currentlyEditing){
        [currentlyEditing resignFirstResponder];
        currentlyEditing = nil;
    }
    [nextResponder becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(isViewingWriterController){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
            [self.tableView setContentInset:contentInsets];
            [self.tableView setScrollIndicatorInsets:contentInsets];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if(isViewingWriterController){
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets contentInsets = UIEdgeInsetsZero;
            [self.tableView setContentInset:contentInsets];
            [self.tableView setScrollIndicatorInsets:contentInsets];
        }];
    
        // the statusBar & navigationBar will un-hide if user actively chooses to hide keyboard
    }
}

- (void) textViewDidBeginEditing:(UITextView *) tv {
    if([tv.text isEqualToString:_DEFAULT_TWEET_PROMPT]){
        [tv setText:@""];
    }
    
    currentlyEditing = tv;
}

- (void)textViewDidChange:(UITextView *)tv
{
    [tweetData setObject:tv.text atIndexedSubscript:tv.tag];
    
    int calcNumberOfLines = (tv.contentSize.height / tv.font.lineHeight);
    NSNumber *prevNumberOfLines = [tweetNumberOfLines objectAtIndex:tv.tag];
    
    if(calcNumberOfLines != prevNumberOfLines.intValue){
        [tweetNumberOfLines setObject:[NSNumber numberWithInt:calcNumberOfLines] atIndexedSubscript:tv.tag];
        CGRect tvFrame = [tv frame];
        tvFrame.size.height = tv.contentSize.height + 8;
        [tv setFrame:tvFrame];

        // This is a hack for the iOS7 UITextView paste bug
        // when you paste, we haven't resized the uitextview frame yet (code above)
        // uitextivew (a scroll view) automatically resizes and scrolls to display the caret
        // we later resize, but the content is already scrolled up and hidden
        // this fixes it but forcing the contentsize to be the actual frame size
        [tv setContentSize:tvFrame.size];
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tv.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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

// ***
//  TODO:
//  swipe to dismiss keyboard like the Messages app
//  should only do this if Swiped DOWN. This triggers on any swipe. Bad UX.
// ***
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if(currentlyEditing){
//        [currentlyEditing resignFirstResponder];
//        currentlyEditing = nil;
//    }
//}

@end
