//
//  DDViewController.m
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import "DDViewController.h"
#import "DDTweetTableViewCell.h"
#import "DDTwitterSearchClient.h"
#import "DDRecentItemsManager.h" //!_only_ reused code in this 'test' -- it is only a very thin wrapper around NSUserDefaults

#define DEFAULT_CELL_HEIGHT 44;

@interface DDViewController ()
@property NSArray *history;
@end

@implementation DDViewController {
    NSIndexPath *_selectedIndexPath;
    DDTwitterSearchClient *_searchClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(startNewSearch) withObject:nil afterDelay:0];
}

- (void)startNewSearch {
    NSString  *text = self.searchBar.text;
    
    if(!text.length) {
        return;
    }
    
    //hide UI
    self.tableView.hidden = YES;
    self.activityIndicator.superview.hidden = NO;
    [self.activityIndicator startAnimating];
    
    //always  alloc one... it'd be better to reset it
    _searchClient = [[DDTwitterSearchClient alloc] init];
    
    //load it and get back our model objects
    [_searchClient startSearchFor:text
                        withCompletionBlock:^(NSArray *newResults, NSError *error) {
                            self.tableView.tableFooterView = _searchClient.hasMoreResults ? self.buttonMoreResults : nil;

                            if(!error) {
                                _selectedIndexPath = nil;
                                [self.tableView reloadData];
                                
                                //saves a 'stack' of searches, trims it and keeps it duplicate free
                                [[DDRecentItemsManager sharedManager] saveSearch:@{@"string":text }
                                                                   forIdentifier:@"TwitterTest"
                                                                           error:nil];
                            }
                            self.tableView.hidden = NO;
                           [self.activityIndicator stopAnimating];
                            self.activityIndicator.superview.hidden = YES;
                        }];
}

- (IBAction)continueSearch:(id)sender {
    self.activityIndicator.superview.hidden = NO;
    [self.activityIndicator startAnimating];
    self.buttonMoreResults.enabled =NO;
    
    [_searchClient continueSearchWithCompletionBlock:^(NSArray *newResults, NSError *error) {
        [self.tableView reloadData];
        if(!_searchClient.hasMoreResults)
            self.tableView.tableFooterView = nil;

        [self.activityIndicator stopAnimating];
        self.activityIndicator.superview.hidden = YES;
        self.buttonMoreResults.enabled =YES;
    }];
}

- (void)updateHistory {
    NSString *text = self.searchBar.text;
    NSArray *saved = [[DDRecentItemsManager sharedManager] savedSearchesforIdentifier:@"TwitterTest"];
    if (text.length) {
        saved = [saved filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"string=%@", text]];
    }
    self.history = saved;
    [self.tableViewHistory reloadData];
}

#pragma mark searchbar handling

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateHistory];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tableViewHistory.hidden = NO;
    [self updateHistory];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self startNewSearch];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tableViewHistory.hidden = YES;
}

#pragma mark - tableview callbacks (delegate & dataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if(aTableView == self.tableViewHistory)
        return [self numberOfSectionsInHistoryTableView:aTableView];
    else
        return [self numberOfSectionsInResultsTableView:aTableView];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if(aTableView == self.tableViewHistory)
        return [self historyTableView:aTableView numberOfRowsInSection:section];
    else
        return [self resultsTableView:aTableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(aTableView == self.tableViewHistory)
        return [self historyTableView:aTableView cellForRowAtIndexPath:indexPath];
    else
        return [self resultsTableView:aTableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(aTableView == self.tableViewHistory)
        return [self historyTableView:aTableView didSelectRowAtIndexPath:indexPath];
    else
        return [self resultsTableView:aTableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(aTableView == self.tableViewHistory)
        return 44;
    else
        return [self resultsTableView:aTableView heightForRowAtIndexPath:indexPath];
}

#pragma mark results table

- (NSInteger)numberOfSectionsInResultsTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)resultsTableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _searchClient.results.count;
}

- (UITableViewCell *)resultsTableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TwitterSearchCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    DDTweetTableViewCell *cell = (DDTweetTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DDTweetTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
    cell.tweet = _searchClient.results[indexPath.row];
    cell.detailTextLabel.numberOfLines = (_selectedIndexPath && _selectedIndexPath.row == indexPath.row) ? 0 : 1;
    
    return cell;
}

- (void)resultsTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndexPath = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    
    if(oldIndexPath && _selectedIndexPath.row != oldIndexPath.row)
        [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath, oldIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_selectedIndexPath && indexPath.row == _selectedIndexPath.row) {
        //return the whole height
        return [DDTweetTableViewCell calculatedHeightForTweet:_searchClient.results[indexPath.row] width:tableView.frame.size.width];
    }
    else {
        return DEFAULT_CELL_HEIGHT;
    }
}
#pragma mark history table

- (NSInteger)numberOfSectionsInHistoryTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)historyTableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.history.count;
}

- (UITableViewCell *)historyTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        static NSString *CellIdentifier = @"HistoryCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
    cell.textLabel.text = self.history[indexPath.row][@"string"];
    return cell;
}

- (void)historyTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchBar.text = self.history[indexPath.row][@"string"];
    [self.tableViewHistory deselectRowAtIndexPath:indexPath animated:NO];

    //clicking will trigger a search
    [self.searchBar resignFirstResponder];
    [self startNewSearch];
}

#pragma mark - about me gimmick

- (IBAction)aboutMe:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About Me" message:@"I hope this app meets your expectations. I'd be happy to hear from you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"homepage", @"resume", @"twitter stream", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL *url = nil;
    switch (buttonIndex) {
        case 1 /*hp*/:
            url = [NSURL URLWithString:@"http://www.pich.info"];
            break;
        case 2 /*re*/:
            url = [NSURL URLWithString:@"http://dominik.pich.info/Home_files/Resume.pdf"];
            break;
        case 3 /*tw*/:
            url = [NSURL URLWithString:@"http://twitter.com/DaijDjan"];
            break;
            
        default:
            break;
    }
    if(url)
        [[UIApplication sharedApplication] openURL:url];
}
@end