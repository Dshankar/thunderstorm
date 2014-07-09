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

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic) NSString *replyID;
@property (nonatomic) NSUInteger currentIndex;
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
        
        UIImageView *twitterImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter.png"]];
        [twitterImage setFrame:CGRectMake(90,(deviceHeight - 114)/2,140,114)];
//        [self.view addSubview:twitterImage];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
//        [self.view setBackgroundColor:[UIColor colorWithRed:(220.0/255) green:(220.0/255) blue:(220.0/255) alpha:1.0]];
//        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        
        _progressView = [[DPMeterView alloc] initWithFrame:CGRectMake(90,(deviceHeight - 114)/2,140,114)];
//        CGPathRef shape = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 140, 114)].CGPath;
//        [_progressView setShape:shape];
        [_progressView setMeterType:DPMeterTypeLinearVertical];
        [_progressView setProgressTintColor:[UIColor linkBlue]];
        [_progressView setTrackTintColor:[UIColor whiteColor]];
        
        
        [self.view addSubview:_progressView];
        [_progressView setProgress:0.25 animated:YES];
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

-(void)beginPublishingTweets:(NSArray *)tweetData
{
    self.tweets = tweetData;
    self.currentIndex = 0;
    self.replyID = NULL;
    
    float duration = 0;
    Settings *settings = [Settings getInstance];
    switch(settings.selectedDuration.intValue){
        case 0:
            duration = 0.4;
            break;
        case 1:
            duration = 2.0;
            break;
        case 2:
            duration = 5.0;
            break;
        case 3:
            duration = 15.0;
            break;
    };
    
    // publish first tweet with zero delay, and the subsequent ones with a delay.
    // synchronized to avoid duplicate
    
    @synchronized(self){
        
        [self publishTweets];

        self.taskTimer = [NSTimer
                          scheduledTimerWithTimeInterval:duration target:self
                          selector:@selector(publishTweets) userInfo:nil repeats:YES];
    }
    
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

-(void) publishTweets
{

    if(currentIndex < tweets.count){
        NSURL *postTweetURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        NSDictionary *postParams = @{
                                     @"status":[NSString stringWithFormat:@"%i/%@",currentIndex+1,[tweets objectAtIndex:currentIndex]],
                                     @"in_reply_to_status_id" : [NSString stringWithFormat:@"%@",self.replyID]
                                     };
        SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:postTweetURL parameters:postParams];
        
        Settings *settings = [Settings getInstance];
        [req setAccount:settings.account];
        [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if(responseData){
                NSLog(@"Tweet %i/ HTTP %d", currentIndex+1, urlResponse.statusCode);
                //        NSLog(@" In Reply To ID %@",self.replyID);

                NSError *error;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:0
                                                 error:&error];

                
                if (error == nil) {
                    self.replyID = [jsonDict objectForKey:@"id_str"];
                }
                
                if(urlResponse.statusCode == 200){
                    int nextIndex = currentIndex + 1;
                    
                    if(nextIndex >= tweets.count){
                        // done
                        if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
                            // modify the logo
                            NSLog(@"Foreground. Display complete and hide UI");
                            // show success
                            [self performSelectorOnMainThread:@selector(displaySuccess) withObject:nil waitUntilDone:YES];
                            NSLog(@"Showing Done Button");
                        } else {
                            NSLog(@"Background. Finished All");
                            NSLog(@"Background time remaining = %.1f seconds", UIApplication.sharedApplication.backgroundTimeRemaining);
                        }
                        
                        [self invalidateTaskAndBackground];
                    } else {
                        // more to go
                        if(UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
                            // modify the logo
                            NSLog(@"Foreground. Display %i/%i progress", currentIndex+1, tweets.count);
                            [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
                        } else {
                            NSLog(@"Background. Finished %i/", currentIndex+1);
                            NSLog(@"Background time remaining = %.1f seconds", UIApplication.sharedApplication.backgroundTimeRemaining);
                        }
                        
                        currentIndex++;
                    }
                } else {
                    // if error, will reattempt to publish this tweet
                    // that's OK, but should react (or else, infinite loop...)

                    // Error immediately.
                    [self showFailure];
                    
                    [self invalidateTaskAndBackground];

                }
            }
        }];
    }
}

- (void)updateProgress
{
    [_progressView setProgress:(currentIndex+1.0)/tweets.count animated:YES];
}

- (void)showFailure
{
    [_progressView setProgressTintColor:[UIColor errorRed]];
    [cancelButton.titleLabel setText:@"Error"];
    [cancelButton setBackgroundColor:[UIColor errorRed]];

//    [UIView animateWithDuration:0.2
//                     animations:^{
//                         _progressView.transform = CGAffineTransformMakeRotation(-1*M_PI);
//                     }
//                     completion:^(BOOL finished){
//
//                     }];

    [_progressView setProgress:0 animated:YES];


}

- (void)displaySuccess
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
