//
//  RootTableViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "EmperorsViewController.h"
#import "EmperorResultsController.h"
#import "EmperorCell.h"
#import "TitlesViewController.h"
#import "ModalWebViewController.h"

#define HKCommonNameSort 0
#define HKDateSort 1

#define HKcommonNamesButtonIndex 0
#define HKInscriptionNamesButtonIndex 1

static NSString *cellIdentifier = @"EmperorNameCell";

@interface EmperorsViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *filteredEmperors;

@end

@implementation EmperorsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // split view controller stuff
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

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
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    // split view controller stuff
    self.titlesViewController = (TitlesViewController *) [[self.splitViewController.viewControllers lastObject] topViewController];
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

- (IBAction)aboutButtonPressed:(UIBarButtonItem *)sender {
    ModalWebViewController *aboutViewController = [[ModalWebViewController alloc] initWithHTMLFileName:@"about"
                                                                                                 title:@"About"
                                                                                modalPresentationStyle:UIModalPresentationFormSheet];
    
    aboutViewController.allowScrolling = NO;
    
    [self presentViewController:aboutViewController animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TitlesViewController *titlesVC = (TitlesViewController *)[segue.destinationViewController topViewController];
    
    NSDictionary *selectedEmperor = [(EmperorCell *)sender emperor];
    
    titlesVC.navigationItem.title = selectedEmperor[@"emperor_common_name"];
    
    titlesVC.emperor = selectedEmperor;
    
    // dismiss keyboard when an emperor is tapped (wouldn't otherwise dismiss with SplitViewController)
    [self.searchController.searchBar resignFirstResponder];
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
                NSString *uReplacedByV = [searchString stringByReplacingOccurrencesOfString:@"u" withString:@"v" options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchString.length)];
                NSRange range = [emperor[@"emperor_inscription_name"] rangeOfString:uReplacedByV options:NSCaseInsensitiveSearch];
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if(!self.searchController.isActive) {
        UIEdgeInsets insets = self.tableView.scrollIndicatorInsets;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(insets.top + 88, insets.left, insets.bottom, insets.right);
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if(self.searchController.isActive) {
        UIEdgeInsets insets = self.tableView.scrollIndicatorInsets;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, insets.left, insets.bottom, insets.right);
    }
}

@end
