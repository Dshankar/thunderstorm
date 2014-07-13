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
        
        tweetId = [[UILabel alloc] initWithFrame:CGRectMake(5,2,20,20)];
        [tweetId setFont:[UIFont fontWithName:@"Lato-Regular" size:16.0f]];
        [tweetId setTextColor:[UIColor mutedGray]];
        [self.textView addSubview:tweetId];
        [self.textView setKeyboardType:UIKeyboardTypeTwitter];
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
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:16.0f]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"1/What's on your mind?" attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(300, 300);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(20,10,280,30) textContainer:container];
    [textView setTextContainerInset:UIEdgeInsetsZero];
    [textView setContentInset:UIEdgeInsetsZero];
    textView.layoutManager.delegate = self;
    
    [self.contentView addSubview:textView];
}

-(CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 3.0;
}

@end
