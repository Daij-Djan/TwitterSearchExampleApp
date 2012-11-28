//
//  DDTweetTableViewCell.m
//  TwitterSearch
//
//  Created by Dominik Pich on 18.11.12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import "DDTweetTableViewCell.h"

@implementation DDTweetTableViewCell

static NSMutableDictionary *_imageCache = nil;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:reuseIdentifier];
}

- (void)setTweet:(NSDictionary *)tweet {
    _tweet = tweet;
    
    //text
    self.detailTextLabel.text = tweet[@"text"];
    
    //user
    if(![tweet[@"to_user"] isKindOfClass:[NSNull class]])
        self.textLabel.text = [NSString stringWithFormat:@"%@ > %@", tweet[@"from_user"], tweet[@"to_user"]];
    else
        self.textLabel.text = tweet[@"from_user"];
    
    //img
    NSString *usernameToLoadImageFor = tweet[@"from_user"];
    //in a real app one would employ better caching
    UIImage *cachedImage = _imageCache[usernameToLoadImageFor];
    if(cachedImage) {
        self.imageView.image = cachedImage;
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        if(!tweet[@"profile_image_url"]) 
            return;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tweet[@"profile_image_url"]]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue] // one should ideally use a different queue here to free main thread and ONLY do the imageView.image setting in Main thread
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error) {
                                       UIImage *newImage = [UIImage imageWithData:data];
                                       self.imageView.image = newImage;
                                       
                                       //save to cache
                                       if(!_imageCache) {
                                           _imageCache = [NSMutableDictionary dictionary];
                                       }
                                       _imageCache[usernameToLoadImageFor] = newImage;
                                   }
                               }];
    }
}

#pragma mark - measure

+ (CGFloat)calculatedHeightForTweet:(id)tweet width:(CGFloat)width {
    //text
    CGSize s1 = [tweet[@"text"] sizeWithFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]
                           constrainedToSize:CGSizeMake(width, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    //user
    NSString *text;
    if(![tweet[@"to_user"] isKindOfClass:[NSNull class]])
        text = [NSString stringWithFormat:@"%@ > %@", tweet[@"from_user"], tweet[@"to_user"]];
    else
        text = tweet[@"from_user"];
    CGSize s2 = [text sizeWithFont:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]]
                          forWidth:width
                     lineBreakMode:NSLineBreakByWordWrapping];
    
    return fmaxf(s1.height + s2.height + /*padding*/ 44, 60);
}

@end
