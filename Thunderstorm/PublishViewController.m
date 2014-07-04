//
//  PublishViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/2/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "PublishViewController.h"
#import "UIColor+ThunderColors.h"

@interface PublishViewController ()

@end

@implementation PublishViewController
@synthesize durationOptions;
@synthesize tv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIButton *publish = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [publish addTarget:self action:@selector(publishToTwitter:) forControlEvents:UIControlEventTouchUpInside];
        [publish setFrame:CGRectMake(0, 508, 320, 60)];
//        [publish setFrame:CGRectMake(0, 350, 200, 60)];
        [publish setTitle:@"Publish to Twitter" forState:UIControlStateNormal];
        [publish.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20.0f]];
        [publish setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
        [publish setBackgroundColor:[UIColor linkBlue]];
        [self.view addSubview:publish];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(0, 20, 36, 36);
        UIImageView *cancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 16, 16)];
        [cancelImageView setImage:[UIImage imageNamed:@"close.png"]];
        [cancelButton addSubview:cancelImageView];
        [cancelButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
//        [self.view setBackgroundColor:[UIColor colorWithRed:(220.0/255) green:(220.0/255) blue:(220.0/255) alpha:1.0]];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 178) style:UITableViewStylePlain];
        tv.delegate = self;
        tv.dataSource = self;
        [self.tv setScrollEnabled:NO];
        
        [self.view addSubview:self.tv];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // hides the navigation bar's bottom 1px grey border
//    CGRect bar = CGRectMake(0, 0, 320, 64);
//    UIGraphicsBeginImageContext(bar.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
//    CGContextFillRect(ctx, bar);
//    UIImage *barImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.durationOptions = @[@"Instant", @"5 seconds", @"15 seconds", @"Exponential"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.durationOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"DurationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20.0f]];
    }
    [cell.textLabel setText:[self.durationOptions objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType != UITableViewCellAccessoryCheckmark){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        for (int c = 0; c < [self.durationOptions count]; c++) {
            if(c != indexPath.row){
                cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:c inSection:0]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"ContentSizeW %f FrameW %f", tableView.contentSize.height, tableView.frame.size.height);
}

- (void)dismissView:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publishToTwitter:(id)sender
{
    
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
