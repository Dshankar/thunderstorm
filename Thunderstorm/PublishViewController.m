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

@interface PublishViewController ()

@property (nonatomic, strong) NSString *timelineId;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic) NSString *replyID;
@property (nonatomic) int currentIndex;
@property (nonatomic) float duration;
@property (nonatomic, strong) NSTimer *taskTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) DPMeterView *progressView;

@end

@implementation PublishViewController

@synthesize tweets;
@synthesize replyID;
@synthesize currentIndex;
@synthesize cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGFloat deviceHeight = UIScreen.mainScreen.bounds.size.height;
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelButton addTarget:self action:@selector(cancelPublishAndDismissView:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(0, deviceHeight - 60, 320, 60)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20.0f]];
        [cancelButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor mutedGray]];
        [self.view addSubview:cancelButton];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
//        [self.view setBackgroundColor:[UIColor colorWithRed:(220.0/255) green:(220.0/255) blue:(220.0/255) alpha:1.0]];
//        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        _progressView = [[DPMeterView alloc] initWithFrame:CGRectMake(90,(deviceHeight - 114)/2,140,114)];
        [_progressView setMeterType:DPMeterTypeLinearVertical];
        [_progressView setProgressTintColor:[UIColor linkBlue]];
        [_progressView setTrackTintColor:[UIColor whiteColor]];
        
        
        [self.view addSubview:_progressView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundTask = UIBackgroundTaskInvalid;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)enterBackground:(NSNotification *)notification
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background expired. Stop background tasks.");
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
}

-(void)beginPublishingTweets:(NSArray *)tweetData onTimeline:(NSString *)timelineTitle Description:(NSString *)timelineDescription
{
    self.tweets = tweetData;
    self.currentIndex = 0;
    self.replyID = NULL;
    
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

    [self createTimeline:timelineTitle];
}

-(void)displayTimelineError
{
    [self showFailure];
    // display descriptive error message here
}

-(void)createTimeline:(NSString *)title
{
    Settings *settings = [Settings getInstance];
    NSURL *createTimelineURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/beta/timelines/custom/create.json"];
    NSDictionary *createTimelineParams = @{
                                           @"name":title,
                                           @"include_entities":@"1",
                                           @"include_user_entities":@"1",
                                           @"include_cards":@"1",
                                           @"send_error_codes":@"1"
                                           };
    
    SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:createTimelineURL parameters:createTimelineParams];
    
    [req setAccount:settings.account];
    
    __block NSError *jsonError = nil;
    __block NSDictionary *jsonResponse = nil;
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(responseData){
            NSLog(@"createTimeline HTTP %li", (long)urlResponse.statusCode);
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
        }
        
        if(jsonError == nil){
            self.timelineId = [[jsonResponse objectForKey:@"response"] objectForKey:@"timeline_id"];
            NSLog(@"Begin Publishing tweets to %@", self.timelineId);
            [_progressView setProgress:0.02 animated:YES];
            [self publishTweet];
        } else {
            NSLog(@"Error on createTimeline with response %@", jsonResponse);
            [self displayTimelineError];
        }
    }];
}

-(void) publishTweet
{
    NSLog(@"publishTweets %i/", currentIndex+1);
    if(currentIndex < tweets.count){
        NSURL *postTweetURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        NSDictionary *postParams = @{
                                     @"status":[NSString stringWithFormat:@"%i/%@",currentIndex+1,[tweets objectAtIndex:currentIndex]],
                                     @"in_reply_to_status_id" : [NSString stringWithFormat:@"%@",self.replyID]
                                     };
        SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:postTweetURL parameters:postParams];
        
        Settings *settings = [Settings getInstance];
        
        __block NSError *jsonError = nil;
        __block NSDictionary *jsonResponse;
        __block NSHTTPURLResponse *httpResponse;
        
        [req setAccount:settings.account];
        [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if(responseData){
                NSLog(@"publishTweet %i/ HTTP %ld", currentIndex+1, (long)urlResponse.statusCode);
                jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                httpResponse = urlResponse;
            }
            
            if (jsonError == nil) {
                self.replyID = [jsonResponse objectForKey:@"id_str"];
            }
            
            if(httpResponse.statusCode == 200){
                [self addTweetToTimeline:self.replyID];
            } else {
                NSLog(@"Error on publishTweets %i/ with response %@", currentIndex+1, jsonResponse);
                [self performSelectorOnMainThread:@selector(showFailure) withObject:nil waitUntilDone:NO];
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
    
    __block NSError *jsonError;
    __block NSDictionary *jsonResponse;
    [req setAccount:settings.account];
    [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(responseData){
            NSLog(@"addTweetToTimeline HTTP %li", (long)urlResponse.statusCode);
            jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
            
            if(jsonError == nil){
                [self performSelectorOnMainThread:@selector(processSuccessfulPublish) withObject:nil waitUntilDone:NO];
            } else {
                NSLog(@"Error on addTweetToTimeline %i/ with response %@", currentIndex, jsonResponse);
                [self performSelectorOnMainThread:@selector(showFailure) withObject:nil waitUntilDone:NO];
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
        if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
            // modify the logo
            NSLog(@"Foreground. Display complete and hide UI");
            [self performSelectorOnMainThread:@selector(showSuccess) withObject:nil waitUntilDone:YES];
        } else {
            NSLog(@"Background. Finished All. %.1f seconds remaining in background.", UIApplication.sharedApplication.backgroundTimeRemaining);
        }
        
        [self invalidateTaskAndBackground];
    } else {
        // more to go
        if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
            // modify the logo
            NSLog(@"Foreground. Display %i/%i progress", currentIndex+1, tweets.count);
            [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
        } else {
            NSLog(@"Background. Finished %i/. %.1f seconds remaining in background.", currentIndex+1, UIApplication.sharedApplication.backgroundTimeRemaining);
        }
        
        currentIndex++;
        NSLog(@"pub next tweet in...%f", self.duration);
        self.taskTimer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(publishTweet) userInfo:nil repeats:NO];
    }
}

- (void)updateProgress
{
    [_progressView setProgress:(currentIndex+1.0)/tweets.count animated:YES];
}

- (void)showFailure
{
    [_progressView setProgressTintColor:[UIColor errorRed]];
    [_progressView setProgress:1.0 animated:YES];
    [cancelButton.titleLabel setText:@"Error"];
    [cancelButton setBackgroundColor:[UIColor errorRed]];
}

- (void)showSuccess
{
    [_progressView setProgress:1.0 animated:YES];
    [_progressView setProgressTintColor:[UIColor successGreen]];
    [cancelButton.titleLabel setText:@"Done"];
    [cancelButton setBackgroundColor:[UIColor successGreen]];
}

- (void)cancelPublishAndDismissView:(id)sender
{
    [self invalidateTaskAndBackground];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)invalidateTaskAndBackground
{
    NSLog(@"invalidateTaskAndBackground");
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
@end
