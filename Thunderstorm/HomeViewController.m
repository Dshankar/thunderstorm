//
//  HomeViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/25/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "HomeViewController.h"
#import "WriterTableViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIColor+ThunderColors.h"
#import "Settings.h"

@interface HomeViewController ()
@property (nonatomic) ACAccountStore *accountStore;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _accountStore = [[ACAccountStore alloc] init];
        
        UIImage *bgImage = [UIImage imageNamed:@"thunderstorm.jpg"];
        UIImageView *bg = [[UIImageView alloc] initWithImage:bgImage];
        bg.frame = self.view.bounds;
        bg.contentMode = UIViewContentModeCenter;
        [self.view addSubview:bg];
        
        // From http://stackoverflow.com/questions/18972994/ios-7-parallax-effect-in-my-view-controller
        UIInterpolatingMotionEffect *horizontalMotionEffect =
        [[UIInterpolatingMotionEffect alloc]
         initWithKeyPath:@"center.x"
         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-60);
        horizontalMotionEffect.maximumRelativeValue = @(60);
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect];
        [bg addMotionEffect:group];
        
        CGFloat deviceHeight = UIScreen.mainScreen.bounds.size.height;
        
        UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, deviceHeight - 60 - 58 - 50 - 100, 280, 100)];
        [mainTitle setNumberOfLines:2];
        [mainTitle setText:@"Welcome to\nThunderstorm"];
        [mainTitle setFont:[UIFont fontWithName:@"Lato-Bold" size:38.0f]];
        [mainTitle setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [self.view addSubview:mainTitle];
        
        UILabel *secondaryTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, deviceHeight - 60 - 58 - 50, 280, 50)];
        [secondaryTitle setNumberOfLines:2];
        [secondaryTitle setText:@"Compose long-form opinions &\nPublish to Twitter"];
        [secondaryTitle setFont:[UIFont fontWithName:@"Lato-Light" size:18.0f]];
        [secondaryTitle setTextColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        [self.view addSubview:secondaryTitle];

        
        UIButton *login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [login addTarget:self action:@selector(loginWithTwitter:) forControlEvents:UIControlEventTouchUpInside];
        [login setFrame:CGRectMake(0, deviceHeight - 60, 320, 60)];
        [login setTitle:@"Login with Twitter" forState:UIControlStateNormal];
        [login.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20.0f]];
        [login setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
        [login setBackgroundColor:[UIColor linkBlue]];
        [self.view addSubview:login];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    return self;
}

- (BOOL) hasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)loginWithTwitter:(id)sender
{
    if([self hasAccessToTwitter]){
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error){
            if(granted){
                NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                if([twitterAccounts count] > 0){
                    [self performSelectorOnMainThread:@selector(showActionSheetWithAccounts:) withObject:twitterAccounts waitUntilDone:YES];
                } else {
                    NSLog(@"No accounts");
                    UIAlertView *noAccounts = [[UIAlertView alloc] initWithTitle:@"Add a Twitter Account" message:@"To use Thunderstorm, add a Twitter account to your iOS device in the Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [noAccounts show];
                }
            } else {
                NSLog(@"Not granted access");
            }
        }];
    } else {
        NSLog(@"No accounts");
        UIAlertView *noAccounts = [[UIAlertView alloc] initWithTitle:@"Add a Twitter Account" message:@"To use Thunderstorm, add a Twitter account to your iOS device in the Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noAccounts show];
    }
}

- (void)showActionSheetWithAccounts:(NSArray *)accounts
{
    UIActionSheet *accountsSheet = [[UIActionSheet alloc] initWithTitle:@"Which Twitter account would you like to use?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for(ACAccount *acct in accounts){
        [accountsSheet addButtonWithTitle:[NSString stringWithFormat:@"@%@",acct.username]];
    }
    accountsSheet.cancelButtonIndex = [accountsSheet addButtonWithTitle:@"Cancel"];
    [accountsSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex){

        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
        ACAccount *chosenOne = [twitterAccounts objectAtIndex:buttonIndex];
        NSLog(@"Selected %@", chosenOne.username);
        Settings *settings = [Settings getInstance];
        settings.account = chosenOne;
        
        [self showWriteScreen];
    }
}

- (void)showWriteScreen
{
    WriterTableViewController *writer = [[WriterTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:writer];
    [navigation.navigationBar setBarTintColor:[UIColor colorWithRed:(28.0/255) green:(28.0/255) blue:(28.0/255) alpha:1.0]];
    [navigation.navigationBar setTranslucent:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self presentViewController:navigation animated:YES completion:nil];
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
