//
//  SettingsTableViewController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 7/3/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "UIColor+ThunderColors.h"
#import "WebsiteViewController.h"
#import "Settings.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController
@synthesize settings;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setTitle:@"Settings"];
        
        settings = [Settings getInstance];
                
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(28.0/255) green:(28.0/255) blue:(28.0/255) alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:20.0f]};

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(20, 30, 320, 14);
    headerLabel.font = [UIFont fontWithName:@"Lato-Light" size:16.0f];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(20, 4, 320, 20);
    headerLabel.font = [UIFont fontWithName:@"Lato-Light" size:16.0f];
    headerLabel.text = [self tableView:tableView titleForFooterInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"DURATION BETWEEN TWEETS";
    } else {
        return nil;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return @"A gap will avoid spamming followers";
    } else if (section == 2) {
        return @"Creative Commons Attribution 3.0";
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch(section)
    {
        case 0:
            return [settings.durationOptions count];
        case 1:
            return 2;
        case 2:
            return 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:18.0f]];
    
    switch(indexPath.section)
    {
        case 0:
            [cell.textLabel setText:[settings.durationOptions objectAtIndex:indexPath.row]];
            if(indexPath.row == settings.selectedDuration.integerValue){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            break;
        case 1:
            if(indexPath.row == 0){
                [cell.textLabel setText:@"Created by @dshankar"];
                [cell.textLabel setTextColor:[UIColor linkBlue]];
            } else {
                [cell.textLabel setText:@"Open Source on Github"];
            }
            break;
        case 2:
            [cell.textLabel setText:@"Photo by Superfamous Studios"];
            break;
        case 3:
            [cell.textLabel setText:@"Log Out of Twitter"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:[UIColor errorRed]];
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType != UITableViewCellAccessoryCheckmark){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                settings.selectedDuration = [NSNumber numberWithInt:indexPath.row];
                for (int c = 0; c < [self.settings.durationOptions count]; c++) {
                    if(c != indexPath.row){
                        cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:c inSection:0]];
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                    }
                }
            }
            break;
        } case 1: {
            if(indexPath.row == 0){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=dshankar"]];
            } else {
                WebsiteViewController *website = [[WebsiteViewController alloc] initWithNibName:nil bundle:nil];
                [website loadURLwithString:@"http://github.com/Dshankar/thunderstorm"];
                [self.navigationController pushViewController:website animated:YES];
            }
            break;
        } case 2: {
            WebsiteViewController *website = [[WebsiteViewController alloc] initWithNibName:nil bundle:nil];
            [website loadURLwithString:@"http://superfamous.com/filter/attribution-3.0"];
            [self.navigationController pushViewController:website animated:YES];
            break;
        } case 3:
            // TODO logout
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
