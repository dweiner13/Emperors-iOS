//
//  EmperorSearchTableViewController.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface EmperorResultsController : UITableViewController <UISearchResultsUpdating>

@property (strong, nonatomic) RootViewController *RVC;
- (instancetype) initWithEmperors:(NSArray *)emperors;

@end
