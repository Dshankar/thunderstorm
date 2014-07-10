//
//  PublishViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/2/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishViewController : UIViewController

-(void)beginPublishingTweets:(NSArray *)tweetData onTimeline:(NSString *)timelineId;

@end
