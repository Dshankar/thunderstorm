//
//  WriterTableViewHeader.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/14/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriterTableViewHeader : UIView

@property (nonatomic, retain) UIButton* publishButton;
@property (nonatomic, retain) UITextView* titleTextView;
@property (nonatomic, retain) UILabel* titlePlaceholder;
@property (nonatomic, retain) UITextView* descriptionTextView;
@property (nonatomic, retain) UILabel* descriptionPlaceholder;
@property (nonatomic, retain) UILabel* username;

@end
