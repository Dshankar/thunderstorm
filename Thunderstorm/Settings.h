//
//  Settings.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
    NSArray *durationOptions;
    NSNumber *selectedDuration;
}

@property (nonatomic, retain) NSArray *durationOptions;
@property (nonatomic, retain) NSNumber *selectedDuration;

+(Settings *)getInstance;

@end
