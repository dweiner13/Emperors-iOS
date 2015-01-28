//
//  RootTableViewController.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootTableViewController : UIViewController <UIBarPositioningDelegate>

@property (copy, nonatomic) NSArray *emperorsSortedByCommonName;
@property (copy, nonatomic) NSArray *emperorsSortedByInscriptionName;
@property (assign, nonatomic) BOOL sortByCommonNames;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@end
