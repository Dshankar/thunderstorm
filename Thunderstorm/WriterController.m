//
//  WriterController.m
//  Thunderstorm
//
//  Created by Darshan Shankar on 6/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "WriterController.h"
#import "SyntaxHighlightTextStorage.h"

@interface WriterController ()

@end

@implementation WriterController
{
    UIBarButtonItem* _publishButton;
    SyntaxHighlightTextStorage* _textStorage;
    UITextView* _textView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
        _publishButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishTweets:)];
        [_publishButton setTintColor:[UIColor grayColor]];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(displaySettings:)];
        [settingsButton setTintColor:[UIColor grayColor]];

        [self.navigationItem setLeftBarButtonItem:settingsButton];
        [self.navigationItem setRightBarButtonItem:_publishButton];
        
        [self createTextView];

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

- (void) createTextView
{
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont fontWithName:@"CrimsonText-Roman" size:20.0f]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"1/What's on your mind?" attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(270, CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(25,120,270,300) textContainer:container];
    _textView.delegate = self;
    [self.view addSubview:_textView];
    
}

- (void) publishTweets:(id)sender
{
    
}

- (void) displaySettings:(id)sender
{
    
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
