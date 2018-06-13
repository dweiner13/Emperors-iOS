//
//  TitlesViewController.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/12/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitlesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSDictionary *emperor;
@property (copy, nonatomic) NSArray *titlesSortedByYear;
@property (copy, nonatomic) NSArray *titlesSortedAlphabetically;

@property (nonatomic) BOOL sortByYear;

- (IBAction)sortControlValueChanged:(UISegmentedControl *)sender;
- (void)helpButtonPressed:(UIBarButtonItem *)helpButton;
- (void)showShareSheetWithSourceRect:(CGRect)rect;

@end