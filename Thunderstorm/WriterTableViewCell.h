//
//  WriterTableViewCell.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriterTableViewCell : UITableViewCell <NSLayoutManagerDelegate>

@property (nonatomic, retain) UITextView* textView;
@property (nonatomic, retain) UILabel* tweetId;
@property (nonatomic, retain) UILabel* placeholder;

@end
