//
//  WriterTableViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriterTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *tweetData;

@end
