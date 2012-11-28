//
//  DDViewController.h
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewHistory;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *buttonMoreResults;

- (IBAction)continueSearch:(id)sender;

- (IBAction)aboutMe:(id)sender;

@end
