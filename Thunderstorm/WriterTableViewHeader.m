//
//  WriterTableViewHeader.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/14/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterTableViewHeader.h"
#import "UIColor+ThunderColors.h"

@implementation WriterTableViewHeader

@synthesize titleTextView;
@synthesize titlePlaceholder;
@synthesize descriptionTextView;
@synthesize descriptionPlaceholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 30.0)];
        [self.titleTextView setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        self.titleTextView.tag = -2;
        [self addSubview:titleTextView];
        
        self.titlePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 27.0, 280.0, 25.0)];
        [self.titlePlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:22.0f]];
        [self.titlePlaceholder setTextColor:[UIColor mutedGray]];
        [self.titlePlaceholder setText:@"Moby Dick"];
        [self addSubview:titlePlaceholder];
                
        self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 90.0)];
        [self.descriptionTextView setFont:[UIFont fontWithName:@"Lato-Bold" size:19.0f]];
        self.descriptionTextView.tag = -1;
        [self addSubview:descriptionTextView];
        
        self.descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 87.0, 280.0, 25.0)];
        [self.descriptionPlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:19.0f]];
        [self.descriptionPlaceholder setTextColor:[UIColor mutedGray]];
        [self.descriptionPlaceholder setText:@"A story about whales."];
        [self addSubview:descriptionPlaceholder];
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
