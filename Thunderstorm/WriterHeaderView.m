//
//  WriterHeaderView.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/14/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterHeaderView.h"
#import "UIColor+ThunderColors.h"

@implementation WriterHeaderView

@synthesize titleTextView;
@synthesize titlePlaceholder;
@synthesize descriptionTextView;
@synthesize descriptionPlaceholder;
@synthesize username;
@synthesize publishButton;
@synthesize settingsButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 80.0)];
        [self.titleTextView setFont:[UIFont fontWithName:@"Lato-Bold" size:25.0f]];
        self.titleTextView.tag = -2;
//        self.titleTextView.returnKeyType = UIReturnKeyNext;
        [self.titleTextView setKeyboardType:UIKeyboardTypeTwitter];
        [self.contentView addSubview:titleTextView];
        
        self.titlePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 31.0, 280.0, 25.0)];
        [self.titlePlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:25.0f]];
        [self.titlePlaceholder setTextColor:[UIColor mutedGray]];
        [self.titlePlaceholder setText:@"Moby Dick"];
        [self.contentView addSubview:titlePlaceholder];
        
        self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 90.0, 280.0, 110.0)];
        [self.descriptionTextView setFont:[UIFont fontWithName:@"Lato-Regular" size:19.0f]];
        self.descriptionTextView.tag = -1;
//        self.descriptionTextView.returnKeyType = UIReturnKeyNext;
        [self.descriptionTextView setKeyboardType:UIKeyboardTypeTwitter];
        [self.contentView addSubview:descriptionTextView];
        
        self.descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 97.0, 280.0, 25.0)];
        [self.descriptionPlaceholder setFont:[UIFont fontWithName:@"Lato-Regular" size:19.0f]];
        [self.descriptionPlaceholder setTextColor:[UIColor mutedGray]];
        [self.descriptionPlaceholder setText:@"A story about whales"];
        [self.contentView addSubview:descriptionPlaceholder];
        
        self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.publishButton setFrame:CGRectMake(236.0, 195.0, 64.0, 30.0)];
        [self.publishButton setBackgroundImage:[UIImage imageNamed:@"publish.png"] forState:UIControlStateNormal];
//        [self.contentView addSubview:self.publishButton];
        
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.settingsButton setFrame:CGRectMake(25.0, 202.0, 16.0, 16.0)];
        [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"settings-grey.png"] forState:UIControlStateNormal];
//        [self.contentView addSubview:self.settingsButton];
        
        self.username = [[UILabel alloc] initWithFrame:CGRectMake(48.0, 199.0, 150.0, 20.0)];
        [self.username setFont:[UIFont fontWithName:@"Lato-Light" size:15.0f]];
        [self.username setTextColor:[UIColor defaultGray]];
        [self.username setText:@"@dshankar"];
//        [self.contentView addSubview:username];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 235.0, self.contentView.bounds.size.width, 1.0)];
        seperator.backgroundColor = [UIColor ultraLightGray];
//        [self.contentView addSubview:seperator];
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
//        [self.titleTextView setBackgroundColor:[UIColor greenColor]];
//        [self.titlePlaceholder setBackgroundColor:[UIColor blueColor]];
//        
//        [self.descriptionTextView setBackgroundColor:[UIColor redColor]];
//        [self.descriptionPlaceholder setBackgroundColor:[UIColor orangeColor]];
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
