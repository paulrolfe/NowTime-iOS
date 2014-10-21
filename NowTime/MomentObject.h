//
//  MomentObject.h
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#define kFacebookShare @"Facebook"
#define kTwitterShare @"Twitter"
#define kPinterestShare @"Pinterest"
#define kGoogleShare @"Google"
#define kTumblrShare @"Tumblr"


@interface MomentObject : NSObject <UIWebViewDelegate>

@property UIWebView * momentWebView;
@property NSURL * url;
@property NSTimer *timer;
@property NSMutableArray * actionsTaken;
@property PFObject * pfObject;
@property float secondsViewed;
@property int loadingCount;

-(id) fetchNewObject;
-(id) initWithObject:(PFObject *)object;
-(void) startTimer;
-(void) pauseTimer;
-(void) sendFeedback;

@end
