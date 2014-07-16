//
//  WriterDescriptionTableViewCell.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/12/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterDescriptionTableViewCell.h"
#import "UIColor+ThunderColors.h"

@implementation WriterDescriptionTableViewCell

@synthesize publishButton;
@synthesize username;
@synthesize titleTextView;
@synthesize descriptionTextView;
@synthesize descriptionPlaceholder;
@synthesize titlePlaceholder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.publishButton setFrame:CGRectMake(236.0, 20.0, 64.0, 30.0)];
//        [self.publishButton setBackgroundImage:[UIImage imageNamed:@"publish.png"] forState:UIControlStateNormal];
//        [self addSubview:publishButton];
        
        self.titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 30.0)];
        [self.titleTextView setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        self.titleTextView.tag = -2;
        [self addSubview:titleTextView];
        
        self.titlePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 27.0, 280.0, 25.0)];
        [self.titlePlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        [self.titlePlaceholder setTextColor:[UIColor mutedGray]];
        [self.titlePlaceholder setText:@"Moby Dick"];
        [self addSubview:titlePlaceholder];
        
//        self.username = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 50.0, 200.0, 20.0)];
//        [self.username setFont:[UIFont fontWithName:@"Lato-Light" size:16.0f]];
//        [self.username setTextColor:[UIColor mutedGray]];
//        [self addSubview:username];
        
        self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 90.0)];
        [self.descriptionTextView setFont:[UIFont fontWithName:@"Lato-Bold" size:19.0f]];
        self.descriptionTextView.tag = -1;
        [self addSubview:descriptionTextView];
        
        self.descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 87.0, 280.0, 25.0)];
        [self.descriptionPlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:19.0f]];
        [self.descriptionPlaceholder setTextColor:[UIColor mutedGray]];
        [self.descriptionPlaceholder setText:@"A story about whales."];
        [self addSubview:descriptionPlaceholder];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
