//
//  PublishViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/2/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "PublishViewController.h"
#import "UIColor+ThunderColors.h"
#import "Settings.h"
#import <Social/Social.h>
#import "DPMeterView.h"
#import "GAIDictionaryBuilder.h"

@interface PublishViewController ()

@property (nonatomic, strong) NSString *timelineId;
@property (nonatomic, strong) NSString *timelineTitle;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic) NSString *replyId;
@property (nonatomic, strong) NSMutableArray *publishedTweetIds;
@property (nonatomic) int currentIndex;
@property (nonatomic) float duration;
@property (nonatomic) float progressPercentage;
@property (nonatomic, strong) NSTimer *taskTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) DPMeterView *progressView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timelineTitleLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *tipMessageLabel;
@property (nonatomic) BOOL isDonePublishing;
@property (nonatomic, strong) NSString *failureMessage;

@end

@implementation PublishViewController

@synthesize tweets;
@synthesize replyId;
@synthesize currentIndex;
@synthesize cancelButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        CGFloat deviceHeight = UIScreen.mainScreen.bounds.size.height;
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelButton addTarget:self action:@selector(cancelPublishAndDismissView:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(0, deviceHeight - 60, 320, 60)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20.0f]];
        [cancelButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor mutedGray]];
        [self.view addSubview:cancelButton];
        
        float statusLabelY;
        float timelineTitleLabelY;
        float progressViewY;
        float tipLabelY;
        float tipMessageLabelY;
        
        if(deviceHeight == 568){
            statusLabelY = 100.0;
            progressViewY = 227.0;
        } else {
            statusLabelY = 50.0;
            progressViewY = 150.0;
        }
        timelineTitleLabelY = statusLabelY + 20;
        tipLabelY = progressViewY + 150;
        tipMessageLabelY = tipLabelY + 0;
        
        _progressView = [[DPMeterView alloc] initWithFrame:CGRectMake(90,progressViewY,140,114)];
        [_progressView setMeterType:DPMeterTypeLinearVertical];
        [_progressView setProgressTintColor:[UIColor linkBlue]];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:0.96 alpha:1.0]];
        
        [_progressView setProgress:0.0];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, statusLabelY, 320, 22)];
        [_statusLabel setText:@"Publishing"];
        [_statusLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:21.0f]];
        [_statusLabel setTextColor:[UIColor mutedGray]];
        [_statusLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_statusLabel];
        
        _timelineTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, timelineTitleLabelY, 320, 30)];
        [_timelineTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_timelineTitleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        [self.view addSubview:_timelineTitleLabel];
        
        _tipMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, tipMessageLabelY, 260, 70)];
        [_tipMessageLabel setNumberOfLines:3];
        [_tipMessageLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:15.0f]];
        [_tipMessageLabel setTextColor:[UIColor defaultGray]];
        [self.view addSubview:_tipMessageLabel];
        
        [self.view addSubview:_progressView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *tip1 = @"Tip: By default, Thunderstorm waits 2 seconds between each tweet to avoid spamming your followers.";
    NSString *tip2 = @"Tip: Reorder tweets before you publish with the long-press gesture on a tweet.";
    NSString *tip3 = @"Tip: Switch to another app while you wait. Thunderstorm will continue to publish in the background ";
    NSArray *tips = @[tip1, tip2, tip3];
    
    int index = arc4random() % 3;
    [_tipMessageLabel setText:[tips objectAtIndex:index]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundTask = UIBackgroundTaskInvalid;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Publish"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)enterBackground:(NSNotification *)notification
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"Background expired. Stop background tasks.");
        if(self.backgroundTask != UIBackgroundTaskInvalid){
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
}

-(void)enterForeground:(NSNotification *)notification
{
    if(self.backgroundTask != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    
    [self displayProgress];
    if(self.isDonePublishing){
        if(self.failureMessage){
            [self showFailure];
        } else {
            [self showSuccess];
        }
    }
}

-(void)beginPublishingTweets:(NSArray *)tweetData onTimeline:(NSString *)newTimelineTitle Description:(NSString *)newTimelineDescription
{
    self.tweets = tweetData;
    self.currentIndex = 0;
    self.replyId = NULL;
    self.publishedTweetIds = [[NSMutableArray alloc] initWithCapacity:tweetData.count];
    self.isDonePublishing = NO;
    self.failureMessage = nil;
    
    Settings *settings = [Settings getInstance];

    switch(settings.selectedDuration.intValue){
        case 0:
            self.duration = 0.4;
            break;
        case 1:
            self.duration = 2.0;
            break;
        case 2:
            self.duration = 5.0;
            break;
        case 3:
            self.duration = 15.0;
            break;
    };

    self.timelineTitle = newTimelineTitle;
    [self.timelineTitleLabel setText:newTimelineTitle];
    [self createTimeline:newTimelineTitle Description:newTimelineDescription];
}

-(void)createTimeline:(NSString *)title Description:(NSString *)description
{
    Settings *settings = [Settings getInstance];
    NSURL *createTimelineURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/beta/timelines/custom/create.json"];
    NSDictionary *createTimelineParams = @{
                                           @"name":title,
                                           @"description":description,
                                           @"include_entities":@"1",
                                           @"include_user_entities":@"1",
                                           @"include_cards":@"1",
                                           @"send_error_codes":@"1"
                                           };
    
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:createTimelineURL parameters:createTimelineParams];
    
    [req setAccount:settings.account];
    
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError;
        NSDictionary *jsonResponse;
        if(responseData){
//            NSLog(@"HTTP %li createTimeline", (long)urlResponse.statusCode);
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
        }
        
        if(urlResponse.statusCode == 200){
            self.timelineId = [[jsonResponse objectForKey:@"response"] objectForKey:@"timeline_id"];
//            NSLog(@"Begin Publishing tweets to %@", self.timelineId);
            
            NSString *urlString = [NSString stringWithFormat:@"www.twitter.com/%@/timelines/%@", settings.account.username, [self.timelineId substringFromIndex:7]];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network_action"
                                                                  action:@"create_timeline"
                                                                   label:urlString
                                                                   value:nil] build]];
            
            [self updateProgress];
            [self publishTweet];
        } else {
            NSLog(@"Error on createTimeline with response %@", jsonResponse);
            [self performSelectorOnMainThread:@selector(setFailedWithMessage:) withObject:@"Couldn't create a Timeline." waitUntilDone:YES];
        }
    }];
}

-(void) publishTweet
{
    if(currentIndex < tweets.count){
        NSURL *postTweetURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        NSDictionary *postParams = @{
                                     @"status":[NSString stringWithFormat:@"%i/%@",currentIndex+1,[tweets objectAtIndex:currentIndex]],
                                     @"in_reply_to_status_id" : [NSString stringWithFormat:@"%@",self.replyId]
                                     };
        SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:postTweetURL parameters:postParams];
        
        Settings *settings = [Settings getInstance];
        
        [req setAccount:settings.account];
        [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSError *jsonError;
            NSDictionary *jsonResponse;
            if(responseData){
//                NSLog(@"HTTP %ld publishTweet %i/", (long)urlResponse.statusCode, currentIndex+1);
                jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            }
            
            if (jsonError == nil) {
                self.replyId = [jsonResponse objectForKey:@"id_str"];
            }
            
            if(urlResponse.statusCode == 200){
                [self.publishedTweetIds setObject:self.replyId atIndexedSubscript:currentIndex];
                [self updateProgress];
                [self performSelectorOnMainThread:@selector(processSuccessfulPublish) withObject:nil waitUntilDone:NO];
            } else {
                NSLog(@"Error on publishTweets %i/ with response %@", currentIndex+1, jsonResponse);
                [self performSelectorOnMainThread:@selector(setFailedWithMessage:) withObject:@"Couldn't publish tweet." waitUntilDone:YES];
                [self invalidateTaskAndBackground];
            }
        }];
    }
}

-(void)addTweetToTimeline:(NSString *)tweetId
{
    Settings *settings = [Settings getInstance];
    NSURL *addToTimelineURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/beta/timelines/custom/add.json"];
    NSDictionary *addToTimelineParams = @{
                                          @"id":self.timelineId,
                                          @"tweet_id":tweetId,
                                          @"include_entities":@"1",
                                          @"include_user_entities":@"1",
                                          @"include_cards":@"1",
                                          @"send_error_codes":@"1"
                                          };
    
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:addToTimelineURL parameters:addToTimelineParams];
    
    [req setAccount:settings.account];
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError;
        NSDictionary *jsonResponse;
        if(responseData){
//            NSLog(@"HTTP %li addTweetToTimeline", (long)urlResponse.statusCode);
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
            
            if(jsonError == nil){
                [self updateProgress];
                [self performSelectorOnMainThread:@selector(processSuccessfulAddToTimeline) withObject:nil waitUntilDone:NO];
            } else {
                NSLog(@"Error on addTweetToTimeline %i/ with response %@", currentIndex, jsonResponse);
                [self performSelectorOnMainThread:@selector(setFailedWithMessage:) withObject:@"Couldn't add tweet to Timeline." waitUntilDone:YES];
                [self invalidateTaskAndBackground];
            }
        }
    }];
}

- (void)processSuccessfulPublish
{
    int nextIndex = currentIndex + 1;
    if(nextIndex >= tweets.count){
        // done
        NSArray *reversed = [[self.publishedTweetIds reverseObjectEnumerator] allObjects];
        self.publishedTweetIds = [[NSMutableArray alloc] initWithArray:reversed];
        
        currentIndex = 0;
        [self addTweetToTimeline:[self.publishedTweetIds objectAtIndex:currentIndex]];
    } else {
        // more to go
        currentIndex++;
        self.taskTimer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(publishTweet) userInfo:nil repeats:NO];
    }
}

- (void)processSuccessfulAddToTimeline
{
    int nextIndex = currentIndex + 1;
    if(nextIndex >= self.publishedTweetIds.count)
    {
        // done
        [self publishSuccessTweet];
    } else {
        currentIndex++;
        [self addTweetToTimeline:[self.publishedTweetIds objectAtIndex:currentIndex]];
    }

}

- (void)publishSuccessTweet
{
    Settings *settings = [Settings getInstance];
    NSString *urlString = [NSString stringWithFormat:@"www.twitter.com/%@/timelines/%@", settings.account.username, [self.timelineId substringFromIndex:7]];
    
    NSURL *postTweetURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSDictionary *postParams = @{
                                 @"status":[NSString stringWithFormat:@"New post \"%@\" %@ via @thunderstormapp", self.timelineTitle, urlString],
                                 @"in_reply_to_status_id" : [NSString stringWithString:self.replyId]
                                 };
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:postTweetURL parameters:postParams];
    
    [req setAccount:settings.account];
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError;
        NSDictionary *jsonResponse;
        if(responseData){
//            NSLog(@"HTTP %ld publishSuccessTweet", (long)urlResponse.statusCode);
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        }
        
        if(urlResponse.statusCode == 200){
            self.replyId = [jsonResponse objectForKey:@"id_str"];
        
            [self updateProgress];
            [self setSuccess];
            [self invalidateTaskAndBackground];
            
        } else {
            NSLog(@"Error on publishSuccessTweets with response %@", jsonResponse);
            [self setFailedWithMessage:@"Couldn't publish final Timeline tweet."];
            [self invalidateTaskAndBackground];
        }
    }];
}

- (void)updateProgress
{
    // 1 createTimeline, tweets.count publishTweets, tweets.count addToTimelines, 1 publishSuccessTweet
    float updates = (1.0 / ((tweets.count * 2) + 2));
    self.progressPercentage = self.progressPercentage + updates;
//    NSLog(@"Update %f", self.progressPercentage);
    
    if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
        [self performSelectorOnMainThread:@selector(displayProgress) withObject:nil waitUntilDone:YES];
    }
}

- (void)displayProgress
{
    [_progressView setProgress:self.progressPercentage animated:YES];
}

- (void)setFailedWithMessage:(NSString *)message;
{
    self.isDonePublishing = YES;
    self.failureMessage = message;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network_action"
                                                          action:@"failure"
                                                           label:message
                                                           value:nil] build]];
    
    if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
        [self performSelectorOnMainThread:@selector(showFailure) withObject:nil waitUntilDone:YES];
    }
}

- (void)setSuccess
{
    self.isDonePublishing = YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network_action"
                                                          action:@"success_publish"
                                                           label:self.timelineId
                                                           value:nil] build]];
    
    if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
        [self performSelectorOnMainThread:@selector(showSuccess) withObject:nil waitUntilDone:YES];
    }
}

- (void)showFailure
{
    [_progressView setProgressTintColor:[UIColor errorRed]];
    [_progressView setProgress:1.0 animated:YES];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor errorRed]];
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:self.failureMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)showSuccess
{
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setFrame:CGRectMake(236.0, 30.0, 64.0, 30.0)];
    [newButton setBackgroundImage:[UIImage imageNamed:@"new-full.png"] forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(startNewWriter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    
    [_progressView setProgress:1.0 animated:YES];
    [_progressView setProgressTintColor:[UIColor successGreen]];
    [cancelButton setTitle:@"View on Twitter" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor successGreen]];
    [cancelButton removeTarget:self action:@selector(cancelPublishAndDismissView:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(viewOnTwitter:) forControlEvents:UIControlEventTouchUpInside];
    
    [_statusLabel setTextColor:[UIColor successGreen]];
    [_statusLabel setText:@"Published"];
}

- (void)viewOnTwitter:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"view_in_twitter"
                                                           label:@"publish"
                                                           value:nil] build]];
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
    {
        NSString *urlString = [NSString stringWithFormat:@"twitter://status?id=%@", self.replyId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else {
        Settings *settings = [Settings getInstance];
        NSString *urlString = [NSString stringWithFormat:@"https://www.twitter.com/%@/status/%@", settings.account.username, self.replyId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)startNewWriter:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"start_new_writer"
                                                           label:@"publish"
                                                           value:nil] build]];
    
    [self.delegate startNewWriter];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelPublishAndDismissView:(id)sender
{
    [self invalidateTaskAndBackground];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)invalidateTaskAndBackground
{
//    NSLog(@"invalidateTaskAndBackground");
    [self.taskTimer invalidate];
    self.taskTimer = nil;
    if(self.backgroundTask != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
//{
//    PublishViewController *pc = [[PublishViewController alloc] initWithNibName:nil bundle:nil];
//    return pc;
//}

@end
