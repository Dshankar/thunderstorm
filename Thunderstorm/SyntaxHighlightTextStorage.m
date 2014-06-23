//
//  SyntaxHighlightTextStorage.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SyntaxHighlightTextStorage.h"

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
//    NSLog(@"replaceCharactersInRange: %@ with String %@", NSStringFromRange(range), str);
    
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void) setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
//    NSLog(@"setAttributes: %@ in range %@", attrs, NSStringFromRange(range));
    
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
    
    UIColor *defaultGray = [UIColor colorWithRed:(104.0/255) green:(110.0/255) blue:(119.0/255) alpha:1.0];
    UIColor *mutedGray = [UIColor colorWithRed:(190.0/255) green:(196.0/255) blue:(205.0/255) alpha:1.0];
    UIColor *errorRed = [UIColor colorWithRed:(212.0/255) green:(81.0/255) blue:(81.0/255) alpha:1.0];
    
    NSDictionary *defaultGrayAttributes = @{NSForegroundColorAttributeName :defaultGray};
    NSDictionary *mutedGrayAttributes = @{NSForegroundColorAttributeName :mutedGray};
    NSDictionary *errorRedAttributes = @{NSForegroundColorAttributeName :errorRed};
    
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
    UIColor *defaultGray = [UIColor colorWithRed:(104.0/255) green:(110.0/255) blue:(119.0/255) alpha:1.0];
    UIColor *errorRed = [UIColor colorWithRed:(212.0/255) green:(81.0/255) blue:(81.0/255) alpha:1.0];
    NSDictionary *defaultGrayAttributes = @{NSForegroundColorAttributeName :defaultGray};
    NSDictionary *errorRedAttributes = @{NSForegroundColorAttributeName :errorRed};
    
    [self addAttributes:defaultGrayAttributes range:NSMakeRange(0, self.length)];
    
    if(self.length > MAX_TWEET_LENGTH){
        [self addAttributes:errorRedAttributes range:NSMakeRange(MAX_TWEET_LENGTH, self.length - MAX_TWEET_LENGTH)];
    }
}

@end
