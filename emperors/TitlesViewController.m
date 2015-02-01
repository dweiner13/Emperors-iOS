//
//  TitlesViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/12/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "TitlesViewController.h"
#import "NameCell.h"
#import "SortCell.h"

#define HKSortControlSection 0
#define HKNamesSection 1
#define HKTitlesSection 2
#define HKWikiSection 3

#define HKSortControlYearIndex 0
#define HKSortControlAlphaIndex 1

#define HKDefaultsSortKey @"sortIndex"

static NSString *nameCellIdentifier = @"nameCell";
static NSString *titleCellIdentifier = @"titleCell";
static NSString *wikiCellIdentifier = @"wikiCell";
static NSString *sortCellIdentifier = @"sortCell";

static NSString *titlesViewHelpSegueIdentifier = @"TitlesViewHelpSegue";

@interface TitlesViewController ()

@property (copy, nonatomic) NSArray *emperorOfficialNames;
@property (nonatomic) NSArray *helpViewControllers;
@property (nonatomic) SortCell *sortCell;

@end

@implementation TitlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortCell = (SortCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:HKSortControlSection]];
    
    NSUInteger defaultSortIndex = [[NSUserDefaults standardUserDefaults] integerForKey:HKDefaultsSortKey];
    self.sortByYear = (defaultSortIndex == HKSortControlYearIndex);
    self.sortCell.sortControl.selectedSegmentIndex = defaultSortIndex;
    
    if (self.emperor==nil) {
        UIView *defaultView = [[[NSBundle mainBundle] loadNibNamed:@"defaultTitlesView" owner:self options:nil] objectAtIndex:0];
        self.view = defaultView;
    }
    
    self.definesPresentationContext = YES;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell height is
    
    // to compensate for the 1.0f header height for the first section (with sort control)
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    
    UIBarButtonItem *helpBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStylePlain target:self action:@selector(helpButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = helpBarButtonItem;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"dates" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *err;
    NSArray *allTitles = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                          error:&err];
    
    // Filter only the titles we want for our emperor
    NSPredicate *emperorPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *commonName = evaluatedObject[@"emperor_common_name"];
        
        return [commonName isEqualToString:self.emperor[@"emperor_common_name"]];
    }];
    
    NSMutableArray *filteredTitles = [NSMutableArray arrayWithArray: [allTitles filteredArrayUsingPredicate:emperorPredicate]];
    
    NSMutableArray *titlesWithIntYears = [NSMutableArray new];
    
    // Sort the dictionary by year
    
    // Start by converting the 'year' index of each NSDictionary to a NSNumber instead of NSString
    for (NSDictionary *title in filteredTitles) {
        NSMutableDictionary *mTitle = [NSMutableDictionary dictionaryWithDictionary:title];
        mTitle[@"year"] = [NSNumber numberWithInt:((NSString *)mTitle[@"year"]).intValue];
        [titlesWithIntYears addObject:mTitle];
    }
    
    NSSortDescriptor *yearSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"year"
                                                                         ascending:YES];
    NSArray *yearSortDescriptors = [NSArray arrayWithObject:yearSortDescriptor];
    
    self.titlesSortedByYear = [titlesWithIntYears sortedArrayUsingDescriptors:yearSortDescriptors];
    
    NSSortDescriptor *alphaSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                          ascending:YES];
    NSArray *alphaSortDescriptors = [NSArray arrayWithObject:alphaSortDescriptor];
    
    self.titlesSortedAlphabetically = [titlesWithIntYears sortedArrayUsingDescriptors:alphaSortDescriptors];
    
    // Get all the emperor's inscribed names
    self.emperorOfficialNames = [(NSString *)self.emperor[@"emperor_inscription_name"] componentsSeparatedByString:@", "];
}


- (void)sortControlValueChanged:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(sender.selectedSegmentIndex==HKSortControlYearIndex) {
        self.sortByYear = YES;
        
        [self.tableView beginUpdates];
        for (int i =0; i < self.titlesSortedAlphabetically.count; i++) {
            NSUInteger newRow = [self.titlesSortedByYear indexOfObject:self.titlesSortedAlphabetically[i]];
            
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:HKTitlesSection] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:HKTitlesSection]];
            
        }
        [self.tableView endUpdates];
        
        [defaults setInteger:HKSortControlYearIndex forKey:HKDefaultsSortKey];
    }
    else if(sender.selectedSegmentIndex==HKSortControlAlphaIndex) {
        self.sortByYear = NO;
        
        [self.tableView beginUpdates];
        for (int i =0; i < self.titlesSortedAlphabetically.count; i++) {
            NSUInteger newRow = [self.titlesSortedAlphabetically indexOfObject:self.titlesSortedByYear[i]];
            
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:HKTitlesSection] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:HKTitlesSection]];
            
        }
        [self.tableView endUpdates];
        
        [defaults setInteger:HKSortControlAlphaIndex forKey:HKDefaultsSortKey];
    }
}

- (void)helpButtonPressed:(UIBarButtonItem *)helpButton {
    [self performSegueWithIdentifier:titlesViewHelpSegueIdentifier sender:helpButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case HKNamesSection:
            if ([self.emperorOfficialNames count]==1) {
                return @"Inscription name";
            }
            else {
                return @"Inscription names";
            }
            break;
        case HKTitlesSection:
            return @"Titles";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HKSortControlSection:
            return 1;
        case HKNamesSection:
            return [self.emperorOfficialNames count];
            break;
        case HKTitlesSection:
            return [self.titlesSortedByYear count];
        case HKWikiSection:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case HKSortControlSection:
        {
            SortCell *cell = [tableView dequeueReusableCellWithIdentifier:sortCellIdentifier];
            
            cell.sortControl.selectedSegmentIndex = self.sortByYear ? HKSortControlYearIndex : HKSortControlAlphaIndex;
            
            return cell;
            break;
        }
        case HKNamesSection:
        {
            NameCell *cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier];
            
            cell.mainLabel.text = self.emperorOfficialNames[indexPath.row];
            
            return cell;
            break;
        }
        case HKTitlesSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier forIndexPath:indexPath];
            
            if (!self.sortByYear) {
                cell.textLabel.text = self.titlesSortedAlphabetically[indexPath.row][@"title"];
                cell.detailTextLabel.text = self.titlesSortedAlphabetically[indexPath.row][@"date"];
            }
            else {
                
                cell.textLabel.text = self.titlesSortedByYear[indexPath.row][@"title"];
                cell.detailTextLabel.text = self.titlesSortedByYear[indexPath.row][@"date"];
            }
            
            return cell;
            break;
        }
        case HKWikiSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:wikiCellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = [NSString stringWithFormat: @"%@ at Wikipedia", self.emperor[@"emperor_common_name"]];
            
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==HKSortControlSection) {
        return 1.0f;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==HKWikiSection) {
        // get the wiki_url for an arbitrary title in the array
        NSURL *wikiUrl = [NSURL URLWithString:self.titlesSortedByYear[0][@"wiki_url"]];
        
        [[UIApplication sharedApplication] openURL:wikiUrl];
        
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger VCindex = [self.helpViewControllers indexOfObject:viewController];
    
    if(VCindex!=NSNotFound && VCindex!=(self.helpViewControllers.count - 1)) {
        return self.helpViewControllers[VCindex + 1];
    }
    else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger VCindex = [self.helpViewControllers indexOfObject:pageViewController];
    
    if(VCindex!=NSNotFound && VCindex!=0) {
        return self.helpViewControllers[VCindex - 1];
    }
    else {
        return nil;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.helpViewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    NSInteger VCindex = [self.helpViewControllers indexOfObject:pageViewController.viewControllers[0]];
    
    return VCindex;
}

@end
