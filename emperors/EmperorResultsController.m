//
//  EmperorSearchTableViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "EmperorResultsController.h"
#import "EmperorCell.h"
#import "TitlesViewController.h"

#define HKinscriptionNamesButtonIndex 0
#define HKcommonNamesButtonIndex 1

static NSString *cellIdentifier = @"EmperorNameCell";

@interface EmperorResultsController ()

@property (strong, nonatomic) NSArray *emperors;
@property (strong, nonatomic) NSMutableArray *filteredEmperors;

@end

@implementation EmperorResultsController

- (instancetype)initWithEmperors:(NSArray *)emperors {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.emperors = emperors;
        self.filteredEmperors = [NSMutableArray new];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
        self.tableView.rowHeight = 53;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EmperorCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

// this is what is fucking shit up
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.RVC performSegueWithIdentifier:@"showFromSearchResults" sender:[self tableView:self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredEmperors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmperorCell *cell = (EmperorCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.mainLabel.text = self.filteredEmperors[indexPath.row][@"emperor_common_name"];
    cell.subLabel.text = self.filteredEmperors[indexPath.row][@"emperor_inscription_name"];
    cell.emperor = self.filteredEmperors[indexPath.row];
    return cell;
}

#pragma mark - UISearchResultsUpdating Conformance

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    NSInteger buttonIndex = searchController.searchBar.selectedScopeButtonIndex;
    
    [self.filteredEmperors removeAllObjects];
    
    if(searchString.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *emperor, NSDictionary *b) {
            if (buttonIndex==HKcommonNamesButtonIndex) {
                NSRange range = [emperor[@"emperor_common_name"] rangeOfString:searchString options:NSCaseInsensitiveSearch];
                return range.location != NSNotFound;
            }
            else {
                NSRange range = [emperor[@"emperor_inscription_name"] rangeOfString:searchString options:NSCaseInsensitiveSearch];
                return range.location != NSNotFound;
            }
        }];
        
        NSArray *matches = [self.emperors filteredArrayUsingPredicate:predicate];
        
        [self.filteredEmperors addObjectsFromArray:matches];
    }
    
    [self.tableView reloadData];
}

@end
