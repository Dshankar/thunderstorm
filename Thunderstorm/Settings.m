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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            instance = [Settings new];
            instance.durationOptions = @[@"Instant", @"2 seconds", @"5 seconds", @"15 seconds"];
            instance.selectedDuration = [defaults objectForKey:@"selectedDuration"];
            instance.account = nil;
        }
    }
    return instance;
}

-(void)selectDuration:(NSNumber*)index{
    self.selectedDuration = index;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:index forKey:@"selectedDuration"];
    [defaults synchronize];
}

@end
