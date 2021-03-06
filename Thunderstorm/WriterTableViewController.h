//
//  WriterTableViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublishViewController.h"

@interface WriterTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, PublishDataDelegate>

@property (nonatomic, retain) NSMutableArray *tweetData;
@property (nonatomic, retain) NSMutableArray *tweetNumberOfLines;
@property (nonatomic, retain) NSMutableDictionary *timelineData;
@property (nonatomic, retain) NSMutableDictionary *timelineNumberOfLines;
@property (nonatomic, retain) UIBarButtonItem* publishButton;
@property (nonatomic, retain) UIBarButtonItem* disabledPublishButton;

@end
