//
//  WebsiteViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WebsiteViewController.h"

@interface WebsiteViewController ()

@end

@implementation WebsiteViewController
@synthesize webview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        [self.view addSubview:self.webview];
        
        [self.navigationItem setBackBarButtonItem:self.navigationItem.backBarButtonItem];
    }
    return self;
}

-(void)loadURLwithString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:urlReq];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(28.0/255) green:(28.0/255) blue:(28.0/255) alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    


    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:20.0f]} forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
