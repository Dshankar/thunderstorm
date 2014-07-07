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

+(Settings *)getInstance;

@end
