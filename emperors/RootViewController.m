//
//  RootTableViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "RootViewController.h"
#import "EmperorResultsController.h"
#import "EmperorCell.h"
#import "TitlesViewController.h"

#define HKCommonNameSort 0
#define HKDateSort 1

#define HKcommonNamesButtonIndex 0
#define HKInscriptionNamesButtonIndex 1

static NSString *cellIdentifier = @"EmperorNameCell";

@interface RootViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *filteredEmperors;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filteredEmperors = [NSMutableArray new];
    
    self.definesPresentationContext = YES;
    
    // set default sorting
    self.sortMethod = HKDateSort;
    
    // read emperor data from JSON file and initialize both sorted arrays
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emperors" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    NSError *err;
    NSArray *emperors = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:0
                                                 error:&err];
    
    self.emperorsOriginalSort = emperors;
    
    // set up search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    UISearchBar *searchBar = self.searchController.searchBar;
    searchBar.scopeButtonTitles = @[@"Common name", @"Inscription"];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    self.searchController.searchResultsUpdater = self;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchController.dimsBackgroundDuringPresentation = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive && self.searchController.searchBar.text.length!=0) {
        return [self.filteredEmperors count];
    }
    else {
        return [self.emperorsOriginalSort count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmperorCell *cell = (EmperorCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.searchController.isActive && self.searchController.searchBar.text.length!=0) {
        cell.mainLabel.text = self.filteredEmperors[indexPath.row][@"emperor_common_name"];
        cell.subLabel.text = self.filteredEmperors[indexPath.row][@"emperor_inscription_name"];
        cell.emperor = self.filteredEmperors[indexPath.row];
    }
    else {
        cell.mainLabel.text = self.emperorsOriginalSort[indexPath.row][@"emperor_common_name"];
        cell.subLabel.text = self.emperorsOriginalSort[indexPath.row][@"emperor_inscription_name"];
        cell.emperor = self.emperorsOriginalSort[indexPath.row];
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TitlesViewController *titlesVC = segue.destinationViewController;
    
    NSDictionary *selectedEmperor = [(EmperorCell *)sender emperor];
    
    titlesVC.navigationItem.title = selectedEmperor[@"emperor_common_name"];
    
    titlesVC.emperor = selectedEmperor;
}

#pragma mark - UISearchResultsUpdating

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
        
        NSArray *matches = [self.emperorsOriginalSort filteredArrayUsingPredicate:predicate];
        
        [self.filteredEmperors addObjectsFromArray:matches];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

@end
