//
//  RootTableViewController.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TitlesViewController;

@interface EmperorsViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate, UIViewControllerPreviewingDelegate>

@property (copy, nonatomic) NSArray *emperorsOriginalSort;

@property (nonatomic) NSInteger sortMethod;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property (weak, nonatomic) IBOutlet UIToolbar *sortingToolbar;

@property (strong, nonatomic) TitlesViewController *titlesViewController;

@end
