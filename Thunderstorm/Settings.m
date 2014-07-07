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
@synthesize account;

static Settings *instance = nil;

+(Settings *)getInstance
{
    @synchronized(self){
        if(instance == nil){
            instance = [Settings new];
            instance.durationOptions = @[@"Instant", @"2 seconds", @"5 seconds", @"15 seconds"];
            instance.selectedDuration = [NSNumber numberWithInt:2];
            instance.account = nil;
        }
    }
    return instance;
}

@end
