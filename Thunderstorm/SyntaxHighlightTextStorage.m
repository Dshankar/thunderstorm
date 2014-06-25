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

//- (NSUInteger)length
//{
//    NSInteger twLength = [TwitterText tweetLength:self.string];
//    NSInteger bsLength = [_backingStore length];
//    
//    NSLog(@"Twitter length: %d Real length: %d", twLength, bsLength);
//    
//    return bsLength;
//}

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
    [self performMaxLengthStyle];
//    [self performReplacementsForRange:[self editedRange]];
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
    NSString *maxLengthRegexStr = @".{30,}";
    NSString *regex = @"\\s([A-Z]{2,})\\s";
    NSRegularExpression *maxLengthRegex = [NSRegularExpression regularExpressionWithPattern:maxLengthRegexStr options:0 error:nil];
    
    NSDictionary *defaultGrayAttributes = @{NSForegroundColorAttributeName :[UIColor defaultGray]};
    NSDictionary *errorRedAttributes = @{NSForegroundColorAttributeName :[UIColor errorRed]};
    NSDictionary *linkBlueAttributes = @{NSForegroundColorAttributeName :[UIColor linkBlue]};
    
//    [maxLengthRegex enumerateMatchesInString:[_backingStore string]
//                            options:0
//                              range:searchRange
//                         usingBlock:^(NSTextCheckingResult *match,
//                                      NSMatchingFlags flags,
//                                      BOOL *stop){

//                             NSRange matchRange = [match rangeAtIndex:1];
//                             [self addAttributes:errorRedAttributes range:NSMakeRange(30, self.length - 30)];
    
//                             if(NSMaxRange(matchRange)+1 < self.length){
//                                 [self addAttributes:defaultGrayAttributes range:NSMakeRange(NSMaxRange(matchRange)+1, 1)];
//                             }
    
//                         }];

}

- (void)performMaxLengthStyle
{
    const int MAX_TWEET_LENGTH = 140;
    NSDictionary *defaultGrayAttributes = @{NSForegroundColorAttributeName : [UIColor defaultGray]};
    NSDictionary *errorRedAttributes = @{NSForegroundColorAttributeName :[UIColor errorRed ]};
    
    [self addAttributes:defaultGrayAttributes range:NSMakeRange(0, self.length)];
    
    NSInteger twLength = [TwitterText tweetLength:self.string];
    
    if(twLength > MAX_TWEET_LENGTH){
        NSInteger excessCharacters = twLength - MAX_TWEET_LENGTH;
        [self addAttributes:errorRedAttributes range:NSMakeRange(self.length - excessCharacters, excessCharacters)];
    }
}

@end
