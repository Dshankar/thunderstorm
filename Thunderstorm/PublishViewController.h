//
//  PublishViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/2/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PublishDataDelegate <NSObject>
@required
- (void) startNewWriter;
@end

@interface PublishViewController : UIViewController
{
    id <PublishDataDelegate> delegate;
}
@property (retain) id delegate;

-(void)beginPublishingTweets:(NSArray *)tweetData onTimeline:(NSString *)timelineTitle Description:(NSString *)timelineDescription;

@end
