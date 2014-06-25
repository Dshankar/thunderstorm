//
//  HomeViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/25/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "HomeViewController.h"
#import "WriterTableViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIImage *bgImage = [UIImage imageNamed:@"thunderstorm.jpg"];
        UIImageView *bg = [[UIImageView alloc] initWithImage:bgImage];
        bg.frame = self.view.bounds;
        bg.contentMode = UIViewContentModeCenter;
        [self.view addSubview:bg];
        
        // From http://stackoverflow.com/questions/18972994/ios-7-parallax-effect-in-my-view-controller
        // Set horizontal effect
        UIInterpolatingMotionEffect *horizontalMotionEffect =
        [[UIInterpolatingMotionEffect alloc]
         initWithKeyPath:@"center.x"
         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-60);
        horizontalMotionEffect.maximumRelativeValue = @(60);
        
        // Create group to combine both
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect];
        
        // Add both effects to your view
        [bg addMotionEffect:group];
        
        UIButton *write = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [write addTarget:self action:@selector(showWriteScreen:) forControlEvents:UIControlEventTouchUpInside];
        [write setFrame:CGRectMake(30, 360, 140, 50)];
        [write setTitle:@"Write" forState:UIControlStateNormal];
        [write.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:48.0f]];
        [write setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        write.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.view addSubview:write];
        
        UIButton *settings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [settings addTarget:self action:@selector(showSettingsScreen:) forControlEvents:UIControlEventTouchUpInside];
        [settings setFrame:CGRectMake(30, 440, 180, 50)];
        [settings setTitle:@"Settings" forState:UIControlStateNormal];
        [settings.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:44.0f]];
        [settings setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.8] forState:UIControlStateNormal];
        settings.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.view addSubview:settings];
    }
    return self;
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

- (void)showWriteScreen:(id)sender
{
    WriterTableViewController *writer = [[WriterTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:writer];
    [navigation.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)showSettingsScreen:(id)sender
{
    WriterTableViewController *writer = [[WriterTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:writer];
    [navigation.navigationBar setBarTintColor:[UIColor whiteColor]];
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
