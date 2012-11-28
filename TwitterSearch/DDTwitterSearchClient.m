//
//  DDTwitterSearchClient.m
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import "DDTwitterSearchClient.h"

@implementation DDTwitterSearchClient {
    NSMutableArray *_results;
    NSUInteger _latestFetchedPage;
}

@synthesize searchTerm=_searchTerm;
@synthesize results=_results;
@synthesize hasMoreResults=_hasMoreResults;

- (void)startSearchFor:(NSString *)text withCompletionBlock:(void (^)(NSArray *, NSError *))handler {
    _results = [[NSMutableArray alloc] init];
    _latestFetchedPage = 0;
    
    //assert
    NSParameterAssert(text.length);
    NSParameterAssert(handler);
    
    //save it
    _searchTerm = text.copy;

    [self continueSearchWithCompletionBlock:handler];
}

- (void)continueSearchWithCompletionBlock:(void (^)(NSArray *, NSError *))handler {
    NSString *encoded = [_searchTerm stringByAddingPercentEscapesUsingEncoding:
                         NSASCIIStringEncoding];
    
    //build url
    NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@", encoded];
    if(_latestFetchedPage > 0)
        urlString = [urlString stringByAppendingFormat:@"&page=%d", _latestFetchedPage+1];
    
    //request, in a real product one would use constants and a real network lib and stuff
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSArray *results = nil;
                               NSUInteger resultsPerPage = 0;
                               if(!error) {
                                   NSDictionary *parsedJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if(!error) {
                                       results = parsedJson[@"results"];
                                       resultsPerPage = [parsedJson[@"results_per_page"] unsignedIntegerValue];
                                   }
                               }

                               //save
                               [_results addObjectsFromArray:results];
                               _hasMoreResults = results.count==resultsPerPage;
                               
                               
                               //advance
                               _latestFetchedPage++;
                               
                               //tell handler
                               handler(results, error);
                           }];
}

@end
