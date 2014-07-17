//
//  SyntaxHighlightTextStorage.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SyntaxHighlightTextStorage.h"
#import "TwitterText.h"
#import "TwitterTextEntity.h"
#import "UIColor+ThunderColors.h"

@implementation SyntaxHighlightTextStorage
{
    NSMutableAttributedString *_backingStore;
}

- (id) init
{
    if(self = [super init]){
        _backingStore = [NSMutableAttributedString new];
    }
    return self;
}

- (NSString *)string
{
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void) setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void) processEditing
{
    [self performReplacementsForRange:[self editedRange]];
    [self performMaxLengthStyle];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}

- (void)applyStylesToRange:(NSRange)searchRange
{
    NSDictionary *defaultGrayAttributes = @{NSForegroundColorAttributeName :[UIColor defaultGray]};
    NSDictionary *linkBlueAttributes = @{NSForegroundColorAttributeName :[UIColor linkBlue]};
    
    [self addAttributes:defaultGrayAttributes range:searchRange];
    
    NSArray *entities = [TwitterText entitiesInText:[self.string substringWithRange:searchRange]];
    for (int i = 0; i < [entities count]; i++) {
        TwitterTextEntity *entity = entities[i];
        [self addAttributes:linkBlueAttributes range:entity.range];
    }
}

- (void)performMaxLengthStyle
{
    // accounts for index characters "10/"
    // assumes up to 2 digits, max of "99/"
    // for now, this will break if > 99 tweets
    // for now, 1 digit tweets "3/" will have max 139 characters
    const int MAX_TWEET_LENGTH = 137;
    NSDictionary *errorRedAttributes = @{NSForegroundColorAttributeName :[UIColor errorRed ]};
    
    NSInteger twLength = [TwitterText tweetLength:self.string];
    
    if(twLength > MAX_TWEET_LENGTH){
        NSInteger excessCharacters = twLength - MAX_TWEET_LENGTH;
        [self addAttributes:errorRedAttributes range:NSMakeRange(self.length - excessCharacters, excessCharacters)];
    }
}

@end
