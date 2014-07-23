//
//  Settings.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface Settings : NSObject {
    NSArray *durationOptions;
    NSNumber *selectedDuration;
    ACAccount *account;
}

@property (nonatomic, retain) NSArray *durationOptions;
@property (nonatomic, retain) NSNumber *selectedDuration;
@property (nonatomic, retain) ACAccount *account;

@property (nonatomic, retain) NSMutableArray *tweetData;
@property (nonatomic, retain) NSMutableArray *tweetNumberOfLines;
@property (nonatomic, retain) NSMutableDictionary *timelineData;
@property (nonatomic, retain) NSMutableDictionary *timelineNumberOfLines;

+(Settings *)getInstance;
-(void)selectDuration:(NSNumber*)index;
-(void)selectAccount:(ACAccount*)newAccount;
-(void)saveTweets:(NSMutableArray *)tweetD withLines:(NSMutableArray *)tweetLines andTimeline:(NSMutableDictionary *)timelineD withLines:(NSMutableDictionary *)timelineLines;

@end
