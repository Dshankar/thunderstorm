//
//  CreateTimelineViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/9/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateTimelineViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

-(id)initWithStyle:(UITableViewStyle)style Tweets:(NSArray *)tweetData;

@end
