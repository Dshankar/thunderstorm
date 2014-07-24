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
#import "WriterHeaderView.h"
#import "TwitterText.h"
#import "HomeViewController.h"
#import "GAIDictionaryBuilder.h"

@interface WriterTableViewController ()
@end

@implementation WriterTableViewController
{
    UIResponder* currentlyEditing;
}
@synthesize tweetData;
@synthesize tweetNumberOfLines;
@synthesize timelineData;
@synthesize timelineNumberOfLines;
@synthesize publishButton;
@synthesize disabledPublishButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.publishButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"publish.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        
        self.disabledPublishButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"publish-disabled.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(disabledPublishTweets:)];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings-blue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(displaySettings:)];
        [self.navigationItem setLeftBarButtonItem:settingsButton];
        [self.navigationItem setRightBarButtonItem:self.disabledPublishButton];
        
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    Settings *settings = [Settings getInstance];
    self.tweetData = [NSMutableArray arrayWithArray:settings.tweetData];
    self.tweetNumberOfLines = [NSMutableArray arrayWithArray:settings.tweetNumberOfLines];
    self.timelineData = [NSMutableDictionary dictionaryWithDictionary:settings.timelineData];
    self.timelineNumberOfLines = [NSMutableDictionary dictionaryWithDictionary:settings.timelineNumberOfLines];
    
    [self assessPublishButtonState];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)applicationWillResignActive:(NSNotification *)notification
{
    Settings *settings = [Settings getInstance];
    [settings saveTweets:self.tweetData withLines:self.tweetNumberOfLines andTimeline:self.timelineData withLines:self.timelineNumberOfLines];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    Settings *settings = [Settings getInstance];
    if(settings.account == nil){
        HomeViewController *home = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
        home.modalPresentationStyle = UIModalPresentationCurrentContext;
        home.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:home animated:YES completion:nil];
    } else {        
        WriterHeaderView *headerView = (WriterHeaderView *)[self.tableView headerViewForSection:0];
        [headerView.titleTextView becomeFirstResponder];
        currentlyEditing = headerView.titleTextView;
    }
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Writer"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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

- (void) disabledPublishTweets:(id)sender
{
    UIAlertView *disabledPublishError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Enter a title and description first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [disabledPublishError show];
}

- (void) publishTweets:(id)sender
{
    NSString *timelineTitle = [self.timelineData objectForKey:@"title"];
    NSString *timelineDescription = [self.timelineData objectForKey:@"description"];
    
    NSString *lengthErrorMessage;
    NSString *emptyTweetErrorMessage;
    for(int i = 0; i < [tweetData count]; i++){
        int length = [TwitterText tweetLength:[tweetData objectAtIndex:i]];
        if (length == 0){
            emptyTweetErrorMessage = [NSString stringWithFormat:@"Tweet %i/ is empty! Delete empty tweets by swiping left.", i+1];
            break;
        } else if(length > 137){
            lengthErrorMessage = [NSString stringWithFormat:@"Tweet %i/ is too long! Tweets cannot be more than 140 characters  long.", i+1];
            break;
        }
    }
    
    UIAlertView *publishError;
    if(timelineTitle.length > 25){
        publishError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Titles cannot be more than 25 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [publishError show];
    } else if(timelineDescription.length > 160){
        publishError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Descriptions cannot be more than 160 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [publishError show];
    } else if(lengthErrorMessage){
        publishError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:lengthErrorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [publishError show];
    } else if(emptyTweetErrorMessage){
        publishError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:emptyTweetErrorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [publishError show];
    } else {
        PublishViewController *publish = [[PublishViewController alloc] initWithNibName:nil bundle:nil];
    //    publish.view.backgroundColor = [UIColor colorWithRed:45.0/255 green:48.0/255 blue:54.0/255 alpha:0.95];
        publish.view.backgroundColor = [UIColor whiteColor];
        publish.delegate = self;
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:publish animated:NO completion:nil];
        //    [self.navigationController pushViewController:publish animated:YES];
        
        publish.view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            publish.view.alpha = 1;
        }];

        self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [publish beginPublishingTweets:self.tweetData onTimeline:timelineTitle Description:timelineDescription];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                             action:@"show_publish"
                                                              label:@"writer"
                                                              value:[NSNumber numberWithInteger:tweetData.count]] build]];
    }
}

- (void) displaySettings:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"show_settings"
                                                           label:@"writer"
                                                           value:nil] build]];
    
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:settingsNav animated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        seperator.backgroundColor = [UIColor ultraLightGray];
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
    
    NSString *textData = [self.tweetData objectAtIndex:indexPath.row];
    if([textData isEqual:@""]){
        cell.placeholder.hidden = NO;
    } else {
        cell.placeholder.hidden = YES;
    }
    
    [cell.textView setText:textData];
    [cell.tweetId setText:[NSString stringWithFormat:@"%d/", indexPath.row + 1]];
    if(indexPath.row + 1 >= 10){
        [cell.tweetId setFrame:CGRectMake(5, 2, 30, 16)];
        UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,30,16)];
        cell.textView.textContainer.exclusionPaths = @[exclusionPath];
        [cell.placeholder setFrame:CGRectMake(55, 10, 160, 20)];
    } else {
        [cell.tweetId setFrame:CGRectMake(5, 2, 20, 16)];
        UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,20,16)];
        cell.textView.textContainer.exclusionPaths = @[exclusionPath];
        [cell.placeholder setFrame:CGRectMake(45, 10, 160, 20)];
    }
    
    CGRect tvFrame = [cell.textView frame];
    float lineHeight = cell.textView.font.lineHeight + 3;
    tvFrame.size.height = ([(NSNumber *)[self.tweetNumberOfLines objectAtIndex:indexPath.row] intValue] * lineHeight) + 8;
    [cell.textView setFrame:tvFrame];
    cell.textView.tag = indexPath.row;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WriterHeaderView *headerView = [[WriterHeaderView alloc] initWithFrame:CGRectMake(0,0,320.0,300.0)];
    
    [headerView.titleTextView setDelegate:self];
    [headerView.descriptionTextView setDelegate:self];
    
    NSString *title = [timelineData objectForKey:@"title"];
    NSString *description = [timelineData objectForKey:@"description"];
    [headerView.titleTextView setText:title];
    [headerView.descriptionTextView setText:description];
    if(![title isEqualToString:@""]){
        headerView.titlePlaceholder.hidden = YES;
    }
    if(![description isEqualToString:@""]){
        headerView.descriptionPlaceholder.hidden = YES;
    }
    
    UIView *inputAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    inputAccessory.backgroundColor = [UIColor whiteColor];
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1.0)];
    seperator.backgroundColor = [UIColor ultraLightGray];
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
    
    headerView.titleTextView.inputAccessoryView = inputAccessory;
    headerView.descriptionTextView.inputAccessoryView = inputAccessory;
    
    headerView = [self setFramesForHeader:headerView];
    
    return headerView;
}

- (WriterHeaderView *)setFramesForHeader:(WriterHeaderView *)headerView;
{    
    int titleNumLines = ((NSNumber *)[timelineNumberOfLines objectForKey:@"title"]).intValue;
    int descNumLines = ((NSNumber *)[timelineNumberOfLines objectForKey:@"description"]).intValue;
    float titleFontLineHeight = headerView.titleTextView.font.lineHeight;
    float descFontLineHeight = headerView.descriptionTextView.font.lineHeight;
    float titleHeight = (titleNumLines * titleFontLineHeight) + 20;
    float descHeight = (descNumLines * descFontLineHeight) + 20;
    
    CGRect titleFrame = CGRectMake(20, 10, 280, titleHeight);
    CGRect titlePFrame = CGRectMake(25, 14, 280, 25);
    CGRect descFrame = CGRectMake(20, titleHeight + 1, 280, descHeight);
    CGRect descPFrame = CGRectMake(25, titleHeight + 0, 280, 25);
    
    [headerView.titleTextView setFrame:titleFrame];
    [headerView.titlePlaceholder setFrame:titlePFrame];
    [headerView.descriptionTextView setFrame:descFrame];
    [headerView.descriptionPlaceholder setFrame:descPFrame];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int titleLines = ((NSNumber *)[timelineNumberOfLines objectForKey:@"title"]).intValue;
    int descriptionLines = ((NSNumber *)[timelineNumberOfLines objectForKey:@"description"]).intValue;
    
    int heights = (titleLines * [UIFont fontWithName:@"Lato-Bold" size:25.0f].lineHeight) +
    (descriptionLines * [UIFont fontWithName:@"Lato-Regular" size:19.0f].lineHeight);
    
//    return heights + 100;
    return heights + 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *numLines = [tweetNumberOfLines objectAtIndex:indexPath.row];
    float lineHeight = [UIFont fontWithName:@"Lato-Regular" size:16.0f].lineHeight + 3;
    return (lineHeight * numLines.intValue) + 20 + 8;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if(currentlyEditing){
        [currentlyEditing resignFirstResponder];
        currentlyEditing = nil;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    // TODO THIS DOESNT DO ANYTHING SOMETIMES
    // SOMETIMES, nextResponder / tv must be null? because it doesnt become the responder
    [nextResponder becomeFirstResponder];
}

// this changes the contentInset of the tableView so that content isn't hidden by the keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        [self.tableView setContentInset:contentInsets];
        [self.tableView setScrollIndicatorInsets:contentInsets];
    }];
    
    
}

// this resets the contentInset of the tableView to show everything when there is no keyboard appearing
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        [self.tableView setContentInset:contentInsets];
        [self.tableView setScrollIndicatorInsets:contentInsets];
    }];
    
    // the statusBar & navigationBar will un-hide if user actively chooses to hide keyboard
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void) textViewDidBeginEditing:(UITextView *) tv
{
    currentlyEditing = tv;
}

- (void)textViewDidChange:(UITextView *)tv
{
    // descriptionTextView & titleTextView are separately handled
    if(tv.tag == -1 || tv.tag == -2){
        WriterHeaderView *headerView = (WriterHeaderView *)[self.tableView headerViewForSection:0];
        
        int calcNumberOfLines = (tv.contentSize.height / tv.font.lineHeight);
        NSString *key;
        
        if(tv.tag == -1){
            key = @"description";
            
            if([tv.text isEqual:@""]){
                headerView.descriptionPlaceholder.hidden = NO;
            } else {
                headerView.descriptionPlaceholder.hidden = YES;
            }
            [self.timelineData setObject:tv.text forKey:key];
        } else {
            key = @"title";
            
            if([tv.text isEqual:@""]){
                headerView.titlePlaceholder.hidden = NO;
            } else {
                headerView.titlePlaceholder.hidden = YES;
            }
            [self.timelineData setObject:tv.text forKey:key];
        }
        
        [self assessPublishButtonState];
        
        NSNumber *prevNumberOfLines = [timelineNumberOfLines objectForKey:key];
        if(calcNumberOfLines != prevNumberOfLines.intValue){
            [timelineNumberOfLines setObject:[NSNumber numberWithInt:calcNumberOfLines] forKey:key];
            CGRect tvFrame = [tv frame];
            tvFrame.size.height = tv.contentSize.height + 8;
            [tv setFrame:tvFrame];
            
            [tv setContentSize:tvFrame.size];
            
            headerView = [self setFramesForHeader:headerView];
            
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }
        
    } else {
        WriterTableViewCell *cell = (WriterTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tv.tag inSection:0]];

        if([tv.text isEqualToString:@""]){
            cell.placeholder.hidden = NO;
        } else {
            cell.placeholder.hidden = YES;
        }
        
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

- (void) startNewWriter
{
    self.tweetData = [[NSMutableArray alloc] initWithObjects:@"", nil];
    self.tweetNumberOfLines = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], nil];
    [self.timelineNumberOfLines setObject:[NSNumber numberWithInt:1] forKey:@"title"];
    [self.timelineNumberOfLines setObject:[NSNumber numberWithInt:1] forKey:@"description"];
    [self.timelineData setObject:@"" forKey:@"title"];
    [self.timelineData setObject:@"" forKey:@"description"];
    
    [self.navigationItem setRightBarButtonItem:self.disabledPublishButton];
    
    [self.tableView reloadData];
}

- (void) assessPublishButtonState
{
    NSString *currentTitle = [self.timelineData objectForKey:@"title"];
    NSString *currentDescription = [self.timelineData objectForKey:@"description"];
    if([currentTitle isEqualToString:@""] || [currentDescription isEqualToString:@""]){
        [self.navigationItem setRightBarButtonItem:self.disabledPublishButton];
    } else {
        [self.navigationItem setRightBarButtonItem:self.publishButton];
    }
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
