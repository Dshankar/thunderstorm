//
//  Settings.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "Settings.h"

@implementation Settings
@synthesize selectedDuration;
@synthesize durationOptions;

static Settings *instance = nil;

+(Settings *)getInstance
{
    @synchronized(self){
        if(instance == nil){
            instance = [Settings new];
            instance.durationOptions = @[@"Instant", @"5 seconds", @"15 seconds", @"Exponential"];
            instance.selectedDuration = [NSNumber numberWithInt:0];
        }
    }
    return instance;
}

@end
