//
//  CreateTimelineTableViewCell.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/9/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "CreateTimelineTableViewCell.h"

@implementation CreateTimelineTableViewCell
@synthesize titleField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(15,8, self.frame.size.width - 30, self.frame.size.height - 16)];
        [self.titleField setFont:[UIFont fontWithName:@"Lato-Regular" size:18.0f]];
        [self.titleField setPlaceholder:@"Title"];
        [self.contentView addSubview:self.titleField];
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
