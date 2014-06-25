//
//  TwitterText.m
//
//  Copyright 2012-2014 Twitter, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "TwitterText.h"

#pragma mark - Regular Expressions

//
// These regular expressions are ported from twitter-text-rb on Apr 24 2012.
//

#define TWUControlCharacters        @"\\u0009-\\u000D"
#define TWUSpace                    @"\\u0020"
#define TWUControl85                @"\\u0085"
#define TWUNoBreakSpace             @"\\u00A0"
#define TWUOghamBreakSpace          @"\\u1680"
#define TWUMongolianVowelSeparator  @"\\u180E"
#define TWUWhiteSpaces              @"\\u2000-\\u200A"
#define TWULineSeparator            @"\\u2028"
#define TWUParagraphSeparator       @"\\u2029"
#define TWUNarrowNoBreakSpace       @"\\u202F"
#define TWUMediumMathematicalSpace  @"\\u205F"
#define TWUIdeographicSpace         @"\\u3000"

#define TWUUnicodeSpaces \
    TWUControlCharacters \
    TWUSpace \
    TWUControl85 \
    TWUNoBreakSpace \
    TWUOghamBreakSpace \
    TWUMongolianVowelSeparator \
    TWUWhiteSpaces \
    TWULineSeparator \
    TWUParagraphSeparator \
    TWUNarrowNoBreakSpace \
    TWUMediumMathematicalSpace \
    TWUIdeographicSpace

#define TWUInvalidCharacters        @"\\uFFFE\\uFEFF\\uFFFF\\u202A-\\u202E"

#define TWULatinAccents \
    @"\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF\\u0100-\\u024F\\u0253-\\u0254\\u0256-\\u0257\\u0259\\u025b\\u0263\\u0268\\u026F\\u0272\\u0289\\u02BB\\u1E00-\\u1EFF"

//
// Hashtag
//

#define TWUCyrillicHashtagChars                     @"\\u0400-\\u04FF"
#define TWUCyrillicSupplementHashtagChars           @"\\u0500-\\u0527"
#define TWUCyrillicExtendedAHashtagChars            @"\\u2DE0-\\u2DFF"
#define TWUCyrillicExtendedBHashtagChars            @"\\uA640-\\uA69F"
#define TWUHebrewHashtagChars                       @"\\u0591-\\u05BF\\u05C1-\\u05C2\\u05C4-\\u05C5\\u05C7\\u05D0-\\u05EA\\u05F0-\\u05F4"
#define TWUHebrewPresentationFormsHashtagChars      @"\\uFB12-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFB4F"
#define TWUArabicHashtagChars                       @"\\u0610-\\u061A\\u0620-\\u065F\\u066E-\\u06D3\\u06D5-\\u06DC\\u06DE-\\u06E8\\u06EA-\\u06EF\\u06FA-\\u06FC\\u06FF"
#define TWUArabicSupplementHashtagChars             @"\\u0750-\\u077F"
#define TWUArabicExtendedAHashtagChars              @"\\u08A0\\u08A2-\\u08AC\\u08E4-\\u08FE"
#define TWUArabicPresentationFormsAHashtagChars     @"\\uFB50-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB"
#define TWUArabicPresentationFormsBHashtagChars     @"\\uFE70-\\uFE74\\uFE76-\\uFEFC"
#define TWUZeroWidthNonJoiner                       @"\\u200C"
#define TWUThaiHashtagChars                         @"\\u0E01-\\u0E3A"
#define TWUHangulHashtagChars                       @"\\u0E40-\\u0E4E"
#define TWUHangulJamoHashtagChars                   @"\\u1100-\\u11FF"
#define TWUHangulCompatibilityJamoHashtagChars      @"\\u3130-\\u3185"
#define TWUHangulJamoExtendedAHashtagChars          @"\\uA960-\\uA97F"
#define TWUHangulSyllablesHashtagChars              @"\\uAC00-\\uD7AF"
#define TWUHangulJamoExtendedBHashtagChars          @"\\uD7B0-\\uD7FF"
#define TWUHalfWidthHangulHashtagChars              @"\\uFFA1-\\uFFDC"

#define TWUNonLatinHashtagChars \
    TWUCyrillicHashtagChars \
    TWUCyrillicSupplementHashtagChars \
    TWUCyrillicExtendedAHashtagChars \
    TWUCyrillicExtendedBHashtagChars \
    TWUHebrewHashtagChars \
    TWUHebrewPresentationFormsHashtagChars \
    TWUArabicHashtagChars \
    TWUArabicSupplementHashtagChars \
    TWUArabicExtendedAHashtagChars \
    TWUArabicPresentationFormsAHashtagChars \
    TWUArabicPresentationFormsBHashtagChars \
    TWUZeroWidthNonJoiner \
    TWUThaiHashtagChars \
    TWUHangulHashtagChars \
    TWUHangulJamoHashtagChars \
    TWUHangulCompatibilityJamoHashtagChars \
    TWUHangulJamoExtendedAHashtagChars \
    TWUHangulSyllablesHashtagChars \
    TWUHangulJamoExtendedBHashtagChars \
    TWUHalfWidthHangulHashtagChars

#define TWUKatakanaHashtagChars                 @"\\u30A1-\\u30FA\\u30FC-\\u30FE"
#define TWUKatakanaHalfWidthHashtagChars        @"\\uFF66-\\uFF9F"
#define TWULatinFullWidthHashtagChars           @"\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A"
#define TWUHiraganaHashtagChars                 @"\\u3041-\\u3096\\u3099-\\u309E"
#define TWUCJKExtensionAHashtagChars            @"\\u3400-\\u4DBF"
#define TWUCJKUnifiedHashtagChars               @"\\u4E00-\\u9FFF"
#define TWUCJKExtensionBHashtagChars            @"\\U00020000-\\U0002A6DF"
#define TWUCJKExtensionCHashtagChars            @"\\U0002A700-\\U0002B73F"
#define TWUCJKExtensionDHashtagChars            @"\\U0002B740-\\U0002B81F"
#define TWUCJKSupplementHashtagChars            @"\\U0002F800-\\U0002FA1F\\u3003\\u3005\\u303B"

#define TWUCJKHashtagCharacters \
    TWUKatakanaHashtagChars \
    TWUKatakanaHalfWidthHashtagChars \
    TWULatinFullWidthHashtagChars \
    TWUHiraganaHashtagChars \
    TWUCJKExtensionAHashtagChars \
    TWUCJKUnifiedHashtagChars \
    TWUCJKExtensionBHashtagChars \
    TWUCJKExtensionCHashtagChars \
    TWUCJKExtensionDHashtagChars \
    TWUCJKSupplementHashtagChars

#define TWUPunctuationChars                             @"\\-_!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUPunctuationCharsWithoutHyphen                @"_!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUPunctuationCharsWithoutHyphenAndUnderscore   @"!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUCtrlChars                                    @"\\x00-\\x1F\\x7F"

#define TWHashtagAlpha \
@"[a-z_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUHashtagAlphanumeric \
@"[a-z0-9_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUHashtagBoundary \
@"^|$|[^&a-z0-9_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUValidHashtag \
    @"(?:" TWUHashtagBoundary @")([#＃]" TWUHashtagAlphanumeric @"*" TWHashtagAlpha TWUHashtagAlphanumeric @"*)"

#define TWUEndHashTagMatch      @"\\A(?:[#＃]|://)"

//
// Symbol
//

#define TWUSymbol               @"[a-z]{1,6}(?:[._][a-z]{1,2})?"
#define TWUValidSymbol \
    @"(?:^|[" TWUUnicodeSpaces @"])" \
    @"(\\$" TWUSymbol @")" \
    @"(?=$|\\s|[" TWUPunctuationChars @"])"

//
// Mention and list name
//

#define TWUValidMentionPrecedingChars   @"(?:[^a-zA-Z0-9_!#$%&*@＠]|^|RT:?)"
#define TWUAtSigns                      @"[@＠]"
#define TWUValidUsername                @"\\A" TWUAtSigns @"[a-zA-Z0-9_]{1,20}\\z"
#define TWUValidList                    @"\\A" TWUAtSigns @"[a-zA-Z0-9_]{1,20}/[a-zA-Z][a-zA-Z0-9_\\-]{0,24}\\z"

#define TWUValidMentionOrList \
    @"(" TWUValidMentionPrecedingChars @")" \
    @"(" TWUAtSigns @")" \
    @"([a-zA-Z0-9_]{1,20})" \
    @"(/[a-zA-Z][a-zA-Z0-9_\\-]{0,24})?"

#define TWUValidReply                   @"\\A(?:[" TWUUnicodeSpaces @"])*" TWUAtSigns @"([a-zA-Z0-9_]{1,20})"
#define TWUEndMentionMatch              @"\\A(?:" TWUAtSigns @"|[" TWULatinAccents @"]|://)"

//
// URL
//

#define TWUValidURLPrecedingChars       @"(?:[^a-zA-Z0-9@＠$#＃" TWUInvalidCharacters @"]|^)"

#define TWUDomainValidStartEndChars \
@"[^" \
    TWUPunctuationChars \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUSubdomainValidMiddleChars \
@"[^" \
    TWUPunctuationCharsWithoutHyphenAndUnderscore \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUDomainValidMiddleChars \
@"[^" \
    TWUPunctuationCharsWithoutHyphen \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUValidSubdomain \
@"(?:" \
    @"(?:" TWUDomainValidStartEndChars TWUSubdomainValidMiddleChars @"*)?" TWUDomainValidStartEndChars @"\\." \
@")"

#define TWUValidDomainName \
@"(?:" \
    @"(?:" TWUDomainValidStartEndChars TWUDomainValidMiddleChars @"*)?" TWUDomainValidStartEndChars @"\\." \
@")"

#define TWUValidGTLD \
@"(?:" \
    @"(?:" \
        @"academy|accountants|actor|aero|agency|airforce|archi|arpa|asia|associates|axa|bar|bargains|bayern|berlin|" \
        @"best|bid|bike|biz|black|blackfriday|blue|boutique|build|builders|buzz|cab|camera|camp|capital|cards|care|" \
        @"career|careers|cash|cat|catering|center|ceo|cheap|christmas|citic|claims|cleaning|clinic|clothing|club|" \
        @"codes|coffee|college|cologne|com|community|company|computer|construction|contractors|cooking|cool|coop|" \
        @"country|credit|creditcard|cruises|dance|dating|democrat|dental|desi|diamonds|digital|directory|discount|" \
        @"domains|edu|education|email|engineering|enterprises|equipment|estate|eus|events|exchange|expert|exposed|" \
        @"fail|farm|feedback|finance|financial|fish|fishing|fitness|flights|florist|foo|foundation|frogans|fund|" \
        @"furniture|futbol|gal|gallery|gift|glass|globo|gmo|gop|gov|graphics|gratis|gripe|guitars|guru|haus|holdings|" \
        @"holiday|horse|house|immobilien|industries|info|institute|insure|int|international|investments|jetzt|jobs|" \
        @"kaufen|kim|kitchen|kiwi|koeln|kred|land|lease|lighting|limited|limo|link|london|luxury|management|mango|" \
        @"marketing|media|meet|menu|miami|mil|mobi|moda|moe|monash|moscow|museum|nagoya|name|net|neustar|ninja|nyc|" \
        @"okinawa|onl|org|paris|partners|parts|photo|photography|photos|pics|pictures|pink|plumbing|post|pro|" \
        @"productions|properties|pub|qpon|quebec|recipes|red|reisen|ren|rentals|repair|report|rest|reviews|rich|" \
        @"rocks|rodeo|ruhr|ryukyu|saarland|schule|services|sexy|shiksha|shoes|singles|social|sohu|solar|solutions|" \
        @"soy|supplies|supply|support|surgery|systems|tattoo|tax|technology|tel|tienda|tips|today|tokyo|tools|town|" \
        @"toys|trade|training|travel|university|uno|vacations|vegas|ventures|viajes|villas|vision|vodka|vote|voting|" \
        @"voto|voyage|wang|watch|webcam|wed|wien|wiki|works|wtc|wtf|xxx|xyz|yokohama|zone|дети|москва|онлайн|орг|" \
        @"сайт|بازار|شبكة|संगठन|みんな|世界|中信|中文网|公司|公益|商城|在线|我爱你|政务|机构|游戏|移动|组织机构|网址|网络|集团|삼성|" \
    @")" \
@")"

#define TWUValidCCTLD \
@"(?:" \
    @"(?:" \
        @"ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bl|bm|bn|bo|bq|br|bs|bt|" \
        @"bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cw|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|" \
        @"et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|" \
        @"il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|" \
        @"mc|md|me|mf|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|" \
        @"pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|" \
        @"ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|" \
        @"vi|vn|vu|wf|ws|ye|yt|za|zm|zw|мкд|мон|рф|срб|укр|қаз|الاردن|الجزائر|السعودية|المغرب|امارات|ایران|بھارت|" \
        @"تونس|سودان|سورية|عمان|فلسطين|قطر|مصر|مليسيا|پاکستان|भारत|বাংলা|ভারত|ਭਾਰਤ|ભારત|இந்தியா|இலங்கை|சிங்கப்பூர்|" \
        @"భారత్|ලංකා|ไทย|გე|中国|中國|台湾|台灣|新加坡|香港|한국|" \
    @")" \
@")"

#define TWUValidPunycode                @"(?:xn--[0-9a-z]+)"

#define TWUSimplifiedValidTLDChars      TWUDomainValidStartEndChars
#define TWUSimplifiedValidTLD           TWUSimplifiedValidTLDChars @"{2,}"

#define TWUSimplifiedValidDomain \
@"(?:" \
    TWUValidSubdomain @"*" TWUValidDomainName TWUSimplifiedValidTLD \
@")"

#define TWUURLDomainForValidation \
@"\\A(?:" \
    TWUValidSubdomain @"*" TWUValidDomainName \
    @"(?:" TWUValidGTLD @"|" TWUValidCCTLD @"|" TWUValidPunycode @")" \
@")\\z"

#define TWUValidASCIIDomain \
    @"(?:[a-zA-Z0-9\\-_" TWULatinAccents @"]+\\.)+" \
    @"(?:" TWUValidGTLD @"|" TWUValidCCTLD @"|" TWUValidPunycode @")(?=[^0-9a-z@]|$)"

#define TWUValidTCOURL                  @"https?://t\\.co/[a-zA-Z0-9]+"
#define TWUInvalidShortDomain           @"\\A" TWUValidDomainName TWUValidCCTLD @"\\z"

#define TWUValidPortNumber              @"[0-9]+"
#define TWUValidGeneralURLPathChars     @"[a-zA-Z0-9!\\*';:=+,.$/%#\\[\\]\\-_~&|@" TWULatinAccents @"]"

#define TWUValidURLBalancedParens \
@"\\(" \
    @"(?:" \
        TWUValidGeneralURLPathChars @"+" \
        @"|" \
        @"(?:" \
            @"\\(" \
                TWUValidGeneralURLPathChars @"+" \
            @"\\)" \
        @")" \
    @")" \
@"\\)"

#define TWUValidURLPathEndingChars      @"[a-zA-Z0-9=_#/+\\-" TWULatinAccents @"]|(?:" TWUValidURLBalancedParens @")"

#define TWUValidURLPath \
@"(?:" \
    @"(?:" \
        TWUValidGeneralURLPathChars @"*" \
        @"(?:" TWUValidURLBalancedParens TWUValidGeneralURLPathChars @"*)*" TWUValidURLPathEndingChars \
    @")" \
    @"|" \
    @"(?:" TWUValidGeneralURLPathChars @"+/)" \
@")"

#define TWUValidURLQueryChars           @"[a-zA-Z0-9!?*'\\(\\);:&=+$/%#\\[\\]\\-_\\.,~|@]"
#define TWUValidURLQueryEndingChars     @"[a-zA-Z0-9_&=#/]"

#define TWUSimplifiedValidURL \
@"(" \
    @"(" TWUValidURLPrecedingChars @")" \
    @"(" \
        @"(https?://)?" \
        @"(" TWUSimplifiedValidDomain @")" \
        @"(?::(" TWUValidPortNumber @"))?" \
        @"(/" TWUValidURLPath @"*)?" \
        @"(\\?" TWUValidURLQueryChars @"*" TWUValidURLQueryEndingChars @")?" \
    @")" \
@")"

#pragma mark - Constants

static const NSInteger MaxTweetLength = 140;
static const NSInteger HTTPShortURLLength = 22;
static const NSInteger HTTPSShortURLLength = 23;

@implementation TwitterText

#pragma mark - Public Methods

+ (NSArray*)entitiesInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];

    NSArray *urls = [self URLsInText:text];
    [results addObjectsFromArray:urls];

    NSArray *hashtags = [self hashtagsInText:text withURLEntities:urls];
    [results addObjectsFromArray:hashtags];

    NSArray *symbols = [self symbolsInText:text withURLEntities:urls];
    [results addObjectsFromArray:symbols];

    NSArray *mentionsAndLists = [self mentionsOrListsInText:text];
    NSMutableArray *addingItems = [NSMutableArray array];

    for (TwitterTextEntity *entity in mentionsAndLists) {
        NSRange entityRange = entity.range;
        BOOL found = NO;
        for (TwitterTextEntity *existingEntity in results) {
            if (NSIntersectionRange(existingEntity.range, entityRange).length > 0) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [addingItems addObject:entity];
        }
    }

    [results addObjectsFromArray:addingItems];
    [results sortUsingSelector:@selector(compare:)];

    return results;
}

+ (NSArray*)URLsInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;
    NSRange allRange = NSMakeRange(0, 0);

    while (1) {
        position = NSMaxRange(allRange);
        if (len <= position) {
            break;
        }

        NSTextCheckingResult *urlResult = [[self simplifiedValidURLRegexp] firstMatchInString:text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(position, len - position)];
        if (!urlResult || urlResult.numberOfRanges < 9) {
            break;
        }

        allRange = urlResult.range;
        NSRange precedingRange = [urlResult rangeAtIndex:2];
        NSRange urlRange = [urlResult rangeAtIndex:3];
        NSRange protocolRange = [urlResult rangeAtIndex:4];
        NSRange domainRange = [urlResult rangeAtIndex:5];

        // If protocol is missing and domain contains non-ASCII characters,
        // extract ASCII-only domains.
        if (protocolRange.location == NSNotFound) {
            if (precedingRange.location != NSNotFound && precedingRange.length > 0) {
                NSString *preceding = [text substringWithRange:precedingRange];
                NSRange suffixRange = [preceding rangeOfCharacterFromSet:[self invalidURLWithoutProtocolPrecedingCharSet] options:NSBackwardsSearch | NSAnchoredSearch];
                if (suffixRange.location != NSNotFound) {
                    continue;
                }
            }

            NSInteger domainStart = domainRange.location;
            NSInteger domainEnd = NSMaxRange(domainRange);
            TwitterTextEntity *lastEntity = nil;
            BOOL lastInvalidShortResult = NO;

            while (domainStart < domainEnd) {
                // Include succeeding character for validation
                NSInteger checkingDomainLength = domainEnd - domainStart;
                if (domainStart + checkingDomainLength < len) {
                    checkingDomainLength++;
                }
                NSTextCheckingResult *asciiResult = [[self validASCIIDomainRegexp] firstMatchInString:text options:0 range:NSMakeRange(domainStart, checkingDomainLength)];
                if (!asciiResult) {
                    break;
                }

                urlRange = asciiResult.range;
                lastEntity = [TwitterTextEntity entityWithType:TwitterTextEntityURL range:urlRange];

                NSTextCheckingResult *invalidShortResult = [[self invalidShortDomainRegexp] firstMatchInString:text options:0 range:urlRange];
                lastInvalidShortResult = (invalidShortResult != nil);
                if (!lastInvalidShortResult) {
                    [results addObject:lastEntity];
                }

                domainStart = NSMaxRange(urlRange);
            }

            if (!lastEntity) {
                continue;
            }

            NSRange pathRange = [urlResult rangeAtIndex:7];
            if (pathRange.location != NSNotFound && NSMaxRange(lastEntity.range) == pathRange.location) {
                if (lastInvalidShortResult) {
                    [results addObject:lastEntity];
                }
                NSRange entityRange = lastEntity.range;
                entityRange.length += pathRange.length;
                lastEntity.range = entityRange;
            }

            // Adjust next position
            allRange = lastEntity.range;

        } else {
            // In the case of t.co URLs, don't allow additional path characters
            NSRange tcoRange = [[self validTCOURLRegexp] rangeOfFirstMatchInString:text options:0 range:urlRange];
            if (tcoRange.location != NSNotFound) {
                urlRange.length = tcoRange.length;
            } else {
                // Validate domain with precise pattern
                NSRange validationResult = [[self URLRegexpForValidation] rangeOfFirstMatchInString:text options:0 range:domainRange];
                if (validationResult.location == NSNotFound) {
                    continue;
                }
            }

            TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityURL range:urlRange];
            [results addObject:entity];
        }
    }

    return results;
}

+ (NSArray*)hashtagsInText:(NSString*)text checkingURLOverlap:(BOOL)checkingURLOverlap
{
    if (!text.length) {
        return [NSArray array];
    }

    NSArray *urls = nil;
    if (checkingURLOverlap) {
        urls = [self URLsInText:text];
    }
    return [self hashtagsInText:text withURLEntities:urls];
}

+ (NSArray*)hashtagsInText:(NSString*)text withURLEntities:(NSArray*)urlEntities
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;

    while (1) {
        NSTextCheckingResult *matchResult = [[self validHashtagRegexp] firstMatchInString:text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(position, len - position)];
        if (!matchResult || matchResult.numberOfRanges < 2) {
            break;
        }

        NSRange hashtagRange = [matchResult rangeAtIndex:1];
        BOOL matchOk = YES;

        // Check URL overlap
        for (TwitterTextEntity *urlEntity in urlEntities) {
            if (NSIntersectionRange(urlEntity.range, hashtagRange).length > 0) {
                matchOk = NO;
                break;
            }
        }

        if (matchOk) {
            NSInteger afterStart = NSMaxRange(hashtagRange);
            if (afterStart < len) {
                NSRange endMatchRange = [[self endHashtagRegexp] rangeOfFirstMatchInString:text options:0 range:NSMakeRange(afterStart, len - afterStart)];
                if (endMatchRange.location != NSNotFound) {
                    matchOk = NO;
                }
            }

            if (matchOk) {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityHashtag range:hashtagRange];
                [results addObject:entity];
            }
        }

        position = NSMaxRange(matchResult.range);
    }

    return results;
}

+ (NSArray*)symbolsInText:(NSString*)text checkingURLOverlap:(BOOL)checkingURLOverlap
{
    if (!text.length) {
        return [NSArray array];
    }

    NSArray *urls = nil;
    if (checkingURLOverlap) {
        urls = [self URLsInText:text];
    }
    return [self symbolsInText:text withURLEntities:urls];
}

+ (NSArray*)symbolsInText:(NSString*)text withURLEntities:(NSArray*)urlEntities
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;

    while (1) {
        NSTextCheckingResult *matchResult = [[self validSymbolRegexp] firstMatchInString:text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(position, len - position)];
        if (!matchResult || matchResult.numberOfRanges < 2) {
            break;
        }

        NSRange symbolRange = [matchResult rangeAtIndex:1];
        BOOL matchOk = YES;

        // Check URL overlap
        for (TwitterTextEntity *urlEntity in urlEntities) {
            if (NSIntersectionRange(urlEntity.range, symbolRange).length > 0) {
                matchOk = NO;
                break;
            }
        }

        if (matchOk) {
            TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntitySymbol range:symbolRange];
            [results addObject:entity];
        }

        position = NSMaxRange(matchResult.range);
    }

    return results;
}

+ (NSArray*)mentionedScreenNamesInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSArray *mentionsOrLists = [self mentionsOrListsInText:text];
    NSMutableArray *results = [NSMutableArray array];

    for (TwitterTextEntity *entity in mentionsOrLists) {
        if (entity.type == TwitterTextEntityScreenName) {
            [results addObject:entity];
        }
    }

    return results;
}

+ (NSArray*)mentionsOrListsInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;

    while (1) {
        NSTextCheckingResult *matchResult = [[self validMentionOrListRegexp] firstMatchInString:text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(position, len - position)];
        if (!matchResult || matchResult.numberOfRanges < 5) {
            break;
        }

        NSRange allRange = matchResult.range;
        NSInteger end = NSMaxRange(allRange);

        NSRange endMentionRange = [[self endMentionRegexp] rangeOfFirstMatchInString:text options:0 range:NSMakeRange(end, len - end)];
        if (endMentionRange.location == NSNotFound) {
            NSRange atSignRange = [matchResult rangeAtIndex:2];
            NSRange screenNameRange = [matchResult rangeAtIndex:3];
            NSRange listNameRange = [matchResult rangeAtIndex:4];

            if (listNameRange.location == NSNotFound) {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityScreenName range:NSMakeRange(atSignRange.location, NSMaxRange(screenNameRange) - atSignRange.location)];
                [results addObject:entity];
            } else {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityListName range:NSMakeRange(atSignRange.location, NSMaxRange(listNameRange) - atSignRange.location)];
                [results addObject:entity];
            }
        } else {
            // Avoid matching the second username in @username@username
            end++;
        }

        position = end;
    }

    return results;
}

+ (TwitterTextEntity*)repliedScreenNameInText:(NSString*)text
{
    if (!text.length) {
        return nil;
    }

    NSInteger len = text.length;

    NSTextCheckingResult *matchResult = [[self validReplyRegexp] firstMatchInString:text options:(NSMatchingWithoutAnchoringBounds | NSMatchingAnchored) range:NSMakeRange(0, len)];
    if (!matchResult || matchResult.numberOfRanges < 2) {
        return nil;
    }

    NSRange replyRange = [matchResult rangeAtIndex:1];
    NSInteger replyEnd = NSMaxRange(replyRange);

    NSRange endMentionRange = [[self endMentionRegexp] rangeOfFirstMatchInString:text options:0 range:NSMakeRange(replyEnd, len - replyEnd)];
    if (endMentionRange.location != NSNotFound) {
        return nil;
    }

    return [TwitterTextEntity entityWithType:TwitterTextEntityScreenName range:replyRange];
}

+ (NSInteger)tweetLength:(NSString*)text
{
    return [self tweetLength:text httpURLLength:HTTPShortURLLength httpsURLLength:HTTPSShortURLLength];
}

+ (NSInteger)tweetLength:(NSString*)text httpURLLength:(NSInteger)httpURLLength httpsURLLength:(NSInteger)httpsURLLength
{
    text = [text precomposedStringWithCanonicalMapping];

    if (!text.length) {
        return 0;
    }

    // Remove URLs from text and add t.co length
    NSMutableString *string = [text mutableCopy];
#if !__has_feature(objc_arc)
    [string autorelease];
#endif

    NSInteger urlLengthOffset = 0;
    NSArray *urlEntities = [self URLsInText:text];
    for (NSInteger i=urlEntities.count-1; i>=0; i--) {
        TwitterTextEntity *entity = [urlEntities objectAtIndex:i];
        NSRange urlRange = entity.range;
        NSString *url = [string substringWithRange:urlRange];
        if ([url rangeOfString:@"https" options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].location == 0) {
            urlLengthOffset += httpsURLLength;
        } else {
            urlLengthOffset += httpURLLength;
        }
        [string deleteCharactersInRange:urlRange];
    }

    NSInteger len = string.length;
    NSInteger charCount = len + urlLengthOffset;

    if (len > 0) {
        // Adjust count for non-BMP characters
        UniChar buffer[len];
        [string getCharacters:buffer range:NSMakeRange(0, len)];

        for (NSInteger i=0; i<len; i++) {
            UniChar c = buffer[i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                if (i+1 < len) {
                    UniChar d = buffer[i+1];
                    if (CFStringIsSurrogateLowCharacter(d)) {
                        charCount--;
                        i++;
                    }
                }
            }
        }
    }

    return charCount;
}

+ (NSInteger)remainingCharacterCount:(NSString*)text
{
    return [self remainingCharacterCount:text httpURLLength:HTTPShortURLLength httpsURLLength:HTTPSShortURLLength];
}

+ (NSInteger)remainingCharacterCount:(NSString*)text httpURLLength:(NSInteger)httpURLLength httpsURLLength:(NSInteger)httpsURLLength
{
    return MaxTweetLength - [self tweetLength:text httpURLLength:httpURLLength httpsURLLength:httpsURLLength];
}

#pragma mark - Private Methods

+ (NSRegularExpression*)simplifiedValidURLRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUSimplifiedValidURL options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)URLRegexpForValidation
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUURLDomainForValidation options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validASCIIDomainRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidASCIIDomain options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)invalidShortDomainRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUInvalidShortDomain options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validTCOURLRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidTCOURL options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validHashtagRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidHashtag options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)endHashtagRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUEndHashTagMatch options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validSymbolRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidSymbol options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validMentionOrListRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidMentionOrList options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)validReplyRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUValidReply options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSRegularExpression*)endMentionRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUEndMentionMatch options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

+ (NSCharacterSet*)invalidURLWithoutProtocolPrecedingCharSet
{
    static NSCharacterSet *charSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        charSet = [NSCharacterSet characterSetWithCharactersInString:@"-_./"];
#if !__has_feature(objc_arc)
        [charSet retain];
#endif
    });
    return charSet;
}

+ (NSRegularExpression*)validDomainSucceedingCharRegexp
{
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [[NSRegularExpression alloc] initWithPattern:TWUEndMentionMatch options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return regexp;
}

@end
