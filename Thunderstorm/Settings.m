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

            NSString *ident = [defaults objectForKey:@"selectedAccountIdentifier"];
            if([ident isEqual:@""]){
                instance.account = nil;
            } else {
                ACAccountStore *store = [[ACAccountStore alloc] init];
                ACAccount *chosen = [store accountWithIdentifier:ident];
                instance.account = chosen;
            }

            instance.tweetData = [defaults objectForKey:@"tweetData"];
            instance.tweetNumberOfLines = [defaults objectForKey:@"tweetNumberOfLines"];
            instance.timelineData = [defaults objectForKey:@"timelineData"];
            instance.timelineNumberOfLines = [defaults objectForKey:@"timelineNumberOfLines"];
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

-(void)selectAccount:(ACAccount*)newAccount{
    self.account = newAccount;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newAccount.identifier forKey:@"selectedAccountIdentifier"];
    [defaults synchronize];
}

-(void)saveTweets:(NSMutableArray *)tweetD withLines:(NSMutableArray *)tweetLines andTimeline:(NSMutableDictionary *)timelineD withLines:(NSMutableDictionary *)timelineLines
{
    NSLog(@"Saving Data");
    
    self.tweetData = tweetD;
    self.tweetNumberOfLines = tweetLines;
    self.timelineData = timelineD;
    self.timelineNumberOfLines = timelineLines;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.tweetData forKey:@"tweetData"];
    [defaults setObject:self.tweetNumberOfLines forKey:@"tweetNumberOfLines"];
    [defaults setObject:self.timelineData forKey:@"timelineData"];
    [defaults setObject:self.timelineNumberOfLines forKey:@"timelineNumberOfLines"];
    [defaults synchronize];

}

@end
