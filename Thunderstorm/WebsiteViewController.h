//
//  WebsiteViewController.h
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebsiteViewController : GAITrackedViewController <UIWebViewDelegate>

-(void)loadURLwithString:(NSString *)url;

@property (nonatomic, retain) UIWebView *webview;

@end
