//
//  UIColor+ThunderColors.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/24/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UIColor+ThunderColors.h"

@implementation UIColor (ThunderColors)

// used for text and default application color
+ (UIColor *)defaultGray
{
    return [UIColor colorWithRed:(104.0/255) green:(110.0/255) blue:(119.0/255) alpha:1.0];
//    return [UIColor colorWithRed:(53.0/255) green:(57.0/255) blue:(63.0/255) alpha:1.0];
}

// used in successful events
+ (UIColor *)successGreen
{
    return [UIColor colorWithRed:(62.0/255) green:(226.0/255) blue:(139.0/255) alpha:1.0];
}

// used for tweet indices "1/, 2/, ..."
+ (UIColor *)mutedGray
{
    return [UIColor colorWithRed:(190.0/255) green:(196.0/255) blue:(205.0/255) alpha:1.0];
}

// used for line separators
+ (UIColor *)ultraLightGray
{
    return [UIColor colorWithRed:(232.0/255) green:(236.0/255) blue:(240.0/255) alpha:1.0];
}

// used in error events
+ (UIColor *)errorRed
{
    return [UIColor colorWithRed:(212.0/255) green:(81.0/255) blue:(81.0/255) alpha:1.0];
}

// used to indicate a clickable link such as a button, hashtag, or URL
+ (UIColor *)linkBlue
{
    return [UIColor colorWithRed:(62.0/255) green:(132.0/255) blue:(226.0/255) alpha:1.0];
}

@end

