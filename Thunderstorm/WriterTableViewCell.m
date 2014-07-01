//
//  WriterTableViewCell.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/22/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterTableViewCell.h"
#import "SyntaxHighlightTextStorage.h"
#import "UIColor+ThunderColors.h"

@implementation WriterTableViewCell
{
    SyntaxHighlightTextStorage* _textStorage;
}

@synthesize textView;
@synthesize tweetId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createTextView];
                
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        tweetId = [[UILabel alloc] initWithFrame:CGRectMake(4,4,18,20)];
        [tweetId setFont:[UIFont fontWithName:@"CrimsonText-Roman" size:20.0f]];
        [tweetId setTextColor:[UIColor mutedGray]];
        [self.textView addSubview:tweetId];
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

- (void) createTextView
{
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont fontWithName:@"CrimsonText-Roman" size:20.0f]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"1/What's on your mind?" attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(270, 300);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(25,25,270,30) textContainer:container];
    [textView setTextContainerInset:UIEdgeInsetsZero];
    [textView setContentInset:UIEdgeInsetsZero];
    
    UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,18,20)];
    textView.textContainer.exclusionPaths = @[exclusionPath];
    
    [self.contentView addSubview:textView];
}

@end
