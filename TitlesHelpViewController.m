//
//  TitlesHelpViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "TitlesHelpViewController.h"

static NSString *firstHelpSceneIdentifier = @"titlesHelpScene1";
static NSString *secondHelpSceneIdentifier = @"titlesHelpScene2";

@interface TitlesHelpViewController ()

@property (nonatomic) NSArray *helpViewControllers;

@end

@implementation TitlesHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.helpViewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:firstHelpSceneIdentifier],
                                 [self.storyboard instantiateViewControllerWithIdentifier:secondHelpSceneIdentifier]];
    
    [self setViewControllers:[NSArray arrayWithObject:self.helpViewControllers[0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES completion:nil];
    
    self.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
