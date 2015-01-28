//
//  EmperorCell.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/12/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmperorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) NSDictionary *emperor;

@end
