//
//  UIColor+ThunderColors.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/24/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UIColor+ThunderColors.h"

@implementation UIColor (ThunderColors)

+ (UIColor *)defaultGray
{
    return [UIColor colorWithRed:(104.0/255) green:(110.0/255) blue:(119.0/255) alpha:1.0];
//    return [UIColor colorWithRed:(53.0/255) green:(57.0/255) blue:(63.0/255) alpha:1.0];
}

+ (UIColor *)successGreen
{
    return [UIColor colorWithRed:(62.0/255) green:(226.0/255) blue:(139.0/255) alpha:1.0];
}

+ (UIColor *)mutedGray
{
    return [UIColor colorWithRed:(190.0/255) green:(196.0/255) blue:(205.0/255) alpha:1.0];
}

+ (UIColor *)errorRed
{
    return [UIColor colorWithRed:(212.0/255) green:(81.0/255) blue:(81.0/255) alpha:1.0];
}

+ (UIColor *)linkBlue
{
    return [UIColor colorWithRed:(62.0/255) green:(132.0/255) blue:(226.0/255) alpha:1.0];
}

@end

