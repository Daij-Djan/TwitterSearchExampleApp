//
//  DDTweetTableViewCell.h
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTweetTableViewCell : UITableViewCell

@property(nonatomic) NSDictionary *tweet;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)calculatedHeightForTweet:(id)tweet width:(CGFloat)width;

@end
 