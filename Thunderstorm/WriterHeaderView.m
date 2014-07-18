//
//  WriterHeaderView.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/14/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterHeaderView.h"
#import "UIColor+ThunderColors.h"
#import "SyntaxHighlightTextStorage.h"

@implementation WriterHeaderView
{
    SyntaxHighlightTextStorage *_titleTextStorage;
    SyntaxHighlightTextStorage *_descriptionTextStorage;
}

@synthesize titleTextView;
@synthesize titlePlaceholder;
@synthesize descriptionTextView;
@synthesize descriptionPlaceholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSDictionary *attrs = @{NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:25.0f]};
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Title" attributes:attrs];
        _titleTextStorage = [SyntaxHighlightTextStorage new];
        _titleTextStorage.maxLength = [NSNumber numberWithInt:25];
        _titleTextStorage.defaultColor = [UIColor blackColor];
        [_titleTextStorage appendAttributedString:attrString];
        
        self.titleTextView = [self textViewWithType:@"title" Frame:CGRectMake(20.0, 20.0, 280.0, 80.0)];
        self.titleTextView.tag = -2;
        [self.contentView addSubview:titleTextView];
        
        self.titlePlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 31.0, 280.0, 25.0)];
        [self.titlePlaceholder setFont:[UIFont fontWithName:@"Lato-Bold" size:25.0f]];
        [self.titlePlaceholder setTextColor:[UIColor mutedGray]];
        [self.titlePlaceholder setText:@"Moby Dick"];
        [self.contentView addSubview:titlePlaceholder];
        
        NSDictionary *descriptionAttrs = @{NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:19.0f]};
        NSAttributedString *descriptionAttrString = [[NSAttributedString alloc] initWithString:@"Description" attributes:descriptionAttrs];
        _descriptionTextStorage = [SyntaxHighlightTextStorage new];
        _descriptionTextStorage.maxLength = [NSNumber numberWithInt:160];
        _descriptionTextStorage.defaultColor = [UIColor blackColor];
        [_descriptionTextStorage appendAttributedString:descriptionAttrString];
        
        self.descriptionTextView = [self textViewWithType:@"description" Frame:CGRectMake(20.0, 90.0, 280.0, 110.0)];
        self.descriptionTextView.tag = -1;
        [self.contentView addSubview:descriptionTextView];
        
        self.descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 97.0, 280.0, 25.0)];
        [self.descriptionPlaceholder setFont:[UIFont fontWithName:@"Lato-Regular" size:19.0f]];
        [self.descriptionPlaceholder setTextColor:[UIColor mutedGray]];
        [self.descriptionPlaceholder setText:@"A story about whales"];
        [self.contentView addSubview:descriptionPlaceholder];
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (UITextView *)textViewWithType:(NSString *)type Frame:(CGRect)frame
{
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    CGSize containerSize = CGSizeMake(300, 300);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    if([type isEqualToString:@"title"]){
        [_titleTextStorage addLayoutManager:layoutManager];
    } else if ([type isEqualToString:@"description"]){
        [_descriptionTextStorage addLayoutManager:layoutManager];
    }
    
    UITextView *view = [[UITextView alloc] initWithFrame:frame textContainer:container];
    [view setTextContainerInset:UIEdgeInsetsZero];
    [view setContentInset:UIEdgeInsetsZero];
    [view setKeyboardType:UIKeyboardTypeTwitter];
    
    return view;
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
