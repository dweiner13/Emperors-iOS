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
#import "ModalWebViewController.h"
#import "emperors-Swift.h"

#define HKSortControlSection 0
#define HKNamesSection 1
#define HKTitlesSection 2
#define HKActionSection 3

#define HKSortControlYearIndex 0
#define HKSortControlAlphaIndex 1

#define HKWikiRow 0
#define HKShareRow 1

static NSString *defaultsSortIndexKey = @"sortIndex";

static NSString *nameCellIdentifier = @"nameCell";
static NSString *titleCellIdentifier = @"titleCell";
static NSString *wikiCellIdentifier = @"wikiCell";
static NSString *sortCellIdentifier = @"sortCell";
static NSString *shareCellIdentifier = @"shareCell";

static NSString *titlesViewHelpSegueIdentifier = @"TitlesViewHelpSegue";

static NSInteger estimatedRowHeight = 44.0;

@interface TitlesViewController ()

@property (copy, nonatomic) NSArray *emperorOfficialNames;
@property (nonatomic) NSArray *helpViewControllers;
@property (nonatomic) SortCell *sortCell;

@end

@implementation TitlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortCell = (SortCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:HKSortControlSection]];
    
    NSUInteger defaultSortIndex = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsSortIndexKey];
    self.sortByYear = (defaultSortIndex == HKSortControlYearIndex);
    self.sortCell.sortControl.selectedSegmentIndex = defaultSortIndex;
    
    if (self.emperor==nil) {
        UIView *defaultView = [[[NSBundle mainBundle] loadNibNamed:@"DefaultTitlesView"
                                                             owner:self
                                                           options:nil]
                               objectAtIndex:0];
        self.view = defaultView;
    }
    
    self.definesPresentationContext = YES;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = estimatedRowHeight; // set to whatever your "average" cell height is
    
    // to compensate for the 1.0f header height for the first section (with sort control)
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    
    UIBarButtonItem *helpBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(helpButtonPressed:)];
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
        
        [defaults setInteger:HKSortControlYearIndex forKey:defaultsSortIndexKey];
    }
    else if(sender.selectedSegmentIndex==HKSortControlAlphaIndex) {
        self.sortByYear = NO;
        
        [self.tableView beginUpdates];
        for (int i =0; i < self.titlesSortedAlphabetically.count; i++) {
            NSUInteger newRow = [self.titlesSortedAlphabetically indexOfObject:self.titlesSortedByYear[i]];
            
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:HKTitlesSection] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:HKTitlesSection]];
            
        }
        [self.tableView endUpdates];
        
        [defaults setInteger:HKSortControlAlphaIndex forKey:defaultsSortIndexKey];
    }
}

- (void)helpButtonPressed:(UIBarButtonItem *)helpButton {
    ModalWebViewController *helpViewController = [[ModalWebViewController alloc] initWithHTMLFileName:@"help"
                                                                                                title:@"Help"
                                                                               modalPresentationStyle:UIModalPresentationPageSheet];
    
    [self presentViewController:helpViewController animated:YES completion:nil];
}

-(void)sortButtonPressed:(UIBarButtonItem *)sortButton {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
        case HKActionSection:
            return 2;
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
        }
        case HKNamesSection:
        {
            NameCell *cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier];
            
            cell.mainLabel.text = self.emperorOfficialNames[indexPath.row];
            
            return cell;
        }
        case HKTitlesSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier forIndexPath:indexPath];
            
            if (self.sortByYear) {
                cell.textLabel.text = self.titlesSortedByYear[indexPath.row][@"title"];
                cell.detailTextLabel.text = self.titlesSortedByYear[indexPath.row][@"date"];
            }
            else {
                cell.textLabel.text = self.titlesSortedAlphabetically[indexPath.row][@"title"];
                cell.detailTextLabel.text = self.titlesSortedAlphabetically[indexPath.row][@"date"];
            }
            
            return cell;
        }
        case HKActionSection:
        {
            if (indexPath.row == HKWikiRow) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:wikiCellIdentifier forIndexPath:indexPath];
                
                cell.textLabel.text = [NSString stringWithFormat: @"%@ at Wikipedia", self.emperor[@"emperor_common_name"]];
                
                return cell;
            }
            else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shareCellIdentifier forIndexPath:indexPath];
                
                return cell;
            }
        }
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==HKSortControlSection) {
        return 1.0f;
    }
    return UITableViewAutomaticDimension;
}

- (NSString *)getPlaintext {
    NSArray *titles;
    NSString *plaintext = [NSString stringWithFormat:@"%@\n", self.emperor[@"emperor_common_name"]];
    for (NSString *officialName in self.emperorOfficialNames) {
        NSString *line = [NSString stringWithFormat:@"%@\n", officialName];
        plaintext = [plaintext stringByAppendingString:line];
    }
    if (self.sortByYear) {
        titles = self.titlesSortedByYear;
    }
    else {
        titles = self.titlesSortedAlphabetically;
    }
    for (NSDictionary *titleDict in titles) {
        NSString *title = titleDict[@"title"];
        NSString *date = titleDict[@"date"];
        
        NSString *line = [NSString stringWithFormat:@"%@: %@\n", title, date];
        
        plaintext = [plaintext stringByAppendingString:line];
    }
    
    return plaintext;
}

- (NSString *)getHTML {
    NSArray *titles;
    NSString *HTML = [NSString stringWithFormat:@"<html><body><br /><br /><p style=\"text-align: center; font-size: 120%%; margin-top: 0px; margin-bottom: 3px;\"><b>%@</b></p>", self.emperor[@"emperor_common_name"]];
    
    for (NSString *officialName in self.emperorOfficialNames) {
        NSString *line = [NSString stringWithFormat:@"<p style=\"text-align: center; margin-top: 0px; margin-bottom: 3px; font-family: Academy Engraved LET\">%@</p>", officialName];
        HTML = [HTML stringByAppendingString:line];
    }
    
    HTML = [HTML stringByAppendingString:@"<table>"];
    
    if (self.sortByYear) {
        titles = self.titlesSortedByYear;
    }
    else {
        titles = self.titlesSortedAlphabetically;
    }
    for (NSDictionary *titleDict in titles) {
        NSString *title = titleDict[@"title"];
        NSString *date = titleDict[@"date"];
        
        NSString *line = [NSString stringWithFormat:@"<tr><td><b>%@</b></td><td>%@</td></tr>", title, date];
        
        HTML = [HTML stringByAppendingString:line];
    }
    
    return [HTML stringByAppendingString:@"</table><p>Sent from <a href=\"https://itunes.apple.com/us/app/emperors/id969178209?mt=8\">Emperors</a></p></body></html>"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HKActionSection) {
        if (indexPath.row == HKWikiRow) {
            // get the wiki_url for an arbitrary title in the array
            NSURL *wikiUrl = [NSURL URLWithString:self.titlesSortedByYear[0][@"wiki_url"]];
            
            [[UIApplication sharedApplication] openURL:wikiUrl];
            
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
        }
        else {
            [self showShareSheetWithSourceRect:[self.tableView rectForRowAtIndexPath:indexPath]];
        }
    }
}

- (void)showShareSheetWithSourceRect:(CGRect)rect {
    EmperorShareProvider *shareProvider = [[EmperorShareProvider alloc] initWithPlaceholderString:[self getPlaintext] mailHTMLString:[self getHTML]];
    
    UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareProvider] applicationActivities:nil];
    
    activityController.popoverPresentationController.sourceRect = rect;
    
    [self presentViewController:activityController animated:YES completion:nil];
    
}

@end
