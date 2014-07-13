//
//  WriterDescriptionTableViewCell.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/12/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriterDescriptionTableViewCell : UITableViewCell

@property (nonatomic, retain) UIButton* publishButton;
@property (nonatomic, retain) UITextField* titleTextField;
@property (nonatomic, retain) UITextView* descriptionTextView;
@property (nonatomic, retain) UILabel* descriptionPlaceholder;
@property (nonatomic, retain) UILabel* username;

@end
