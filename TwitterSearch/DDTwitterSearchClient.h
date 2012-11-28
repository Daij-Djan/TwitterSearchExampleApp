//
//  DDTwitterSearchClient.h
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTwitterSearchClient : NSObject

@property(readonly) NSString *searchTerm;
@property(readonly) NSArray *results;
@property(readonly) BOOL hasMoreResults;

- (void)startSearchFor:(NSString*)text
     withCompletionBlock:(void (^)(NSArray *newResults, NSError *error)) handler;

- (void)continueSearchWithCompletionBlock:(void (^)(NSArray *newResults, NSError *error)) handler;

@end
