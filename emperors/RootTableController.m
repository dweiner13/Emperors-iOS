//
//  RootTableViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/11/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "RootTableController.h"

@interface RootTableController ()

@end

@implementation RootTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortByCommonNames = YES;
    
    // read emperor data from JSON file and initialize both sorted arrays
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emperors" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    NSError *err;
    NSArray *emperors = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:0
                                                 error:&err];
    NSSortDescriptor *commonNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"emperor_common_name" ascending:YES];
    NSArray *commonNameSortDescriptors = [NSArray arrayWithObject:commonNameSortDescriptor];
    self.emperorsSortedByCommonName = [emperors sortedArrayUsingDescriptors:commonNameSortDescriptors];
    
    NSSortDescriptor *inscriptionNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"emperor_inscription_name" ascending:YES];
    NSArray *inscriptionNameSortDescriptors = [NSArray arrayWithObject:inscriptionNameSortDescriptor];
    self.emperorsSortedByInscriptionName = [emperors sortedArrayUsingDescriptors:inscriptionNameSortDescriptors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sortButtonPressed:(UIBarButtonItem *)sender {
    if (self.sortByCommonNames) {
        self.sortByCommonNames = 0;
        self.sortButton.title = @"Official";
    } else {
        self.sortByCommonNames = 1;
        self.sortButton.title = @"Common";
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.emperorsSortedByCommonName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EmperorNameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.sortByCommonNames) {
        cell.textLabel.text = self.emperorsSortedByCommonName[[indexPath row]][@"emperor_common_name"];
        cell.detailTextLabel.text = self.emperorsSortedByCommonName[[indexPath row]][@"emperor_inscription_name"];
    }
    else {
        cell.textLabel.text = self.emperorsSortedByInscriptionName[[indexPath row]][@"emperor_inscription_name"];
        cell.detailTextLabel.text = self.emperorsSortedByInscriptionName[[indexPath row]][@"emperor_common_name"];
    }
    
    return cell;
}

- (UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
