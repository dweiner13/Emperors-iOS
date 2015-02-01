//
//  TitlesHelpViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/24/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "TitlesHelpViewController.h"

@interface TitlesHelpViewController ()

@end

@implementation TitlesHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);

    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    
    NSString *helpHtmlPath = [[NSBundle mainBundle] pathForResource:@"help"
                                                            ofType:@"html"];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:helpHtmlPath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil]
                         baseURL:baseURL];
}

- (void) viewWillAppear:(BOOL)animated {
    // on iPad the contentInset does not need to be adjusted for the statusbar
    if (self.view.traitCollection.userInterfaceIdiom==UIUserInterfaceIdiomPad || [UIApplication sharedApplication].statusBarHidden) {
        NSLog(@"Hi!");
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
