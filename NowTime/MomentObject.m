//
//  MomentObject.m
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import "MomentObject.h"

@implementation MomentObject

-(id) fetchNewObjectWithSkip:(NSNumber *)skip{
    //makes a request to parse to get the next object for this usersession.
    self.momentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 2000)];
    self.loadingCount=0;
    self.momentWebView.layer.shadowOpacity=.5;
    self.momentWebView.layer.shadowRadius=10;
    self.momentWebView.delegate=self;
    self.momentWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.momentWebView setSuppressesIncrementalRendering:NO];
    self.momentWebView.scalesPageToFit=YES;
    self.momentWebView.contentMode=UIViewContentModeScaleAspectFit;
    [self nextURLrequestWithSkip:skip];
    self.actionsTaken = [[NSMutableArray alloc] initWithArray:@[]];
    return self;
}

-(void)nextURLrequestWithSkip:(NSNumber *)skip{

    [PFCloud callFunctionInBackground:@"getNextURL"
                       withParameters:@{@"skip" : skip,
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        //the result is the objectID
                                        NSLog(@"Retrieved objectId: %@",result);
                                        //self.url = [NSURL URLWithString:result];
                                        PFQuery * getMoment = [PFQuery queryWithClassName:@"Moment"];
                                        [getMoment getObjectInBackgroundWithId:result block:^(PFObject *object, NSError *error) {
                                            self.pfObject=object;
                                            self.url = [NSURL URLWithString:result];
                                            [self.momentWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
                                        }];
                                    }
                                    else{
                                        [self grabAnyUrl:skip];
                                    }
                                }];
    
}
-(void)grabAnyUrl:(NSNumber *)skip{
    [PFCloud callFunctionInBackground:@"getAnyURL"
                       withParameters:@{@"skip" : skip,
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        //the result is the objectID
                                        NSLog(@"Retrieved objectId: %@",result);
                                        //self.url = [NSURL URLWithString:result];
                                        PFQuery * getMoment = [PFQuery queryWithClassName:@"Moment"];
                                         [getMoment getObjectInBackgroundWithId:result block:^(PFObject *object, NSError *error) {
                                             NSString * urlstring = [NSString stringWithFormat:@"http://nowtime.parseapp.com/%@",result];
                                             self.pfObject=object;
                                             self.url = [NSURL URLWithString:urlstring];
                                             [self.momentWebView loadRequest:[NSURLRequest requestWithURL:self.url]];

                                         }];
                                    }
                                    else{

                                    }
                                }];
}

-(void) startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}
-(void) pauseTimer{
    [self.timer invalidate];
}

- (void)updateTimer:(NSTimer *)timer
{
    self.secondsViewed = self.secondsViewed + 0.1;
}

-(void) sendFeedback{
    PFObject * viewFeedback = [PFObject objectWithClassName:@"View"];
    viewFeedback[@"whoViewed"]=[PFUser currentUser];
    viewFeedback[@"viewedWhat"]=self.pfObject;
    if (self.actionsTaken.count>=1)
        viewFeedback[@"actionsTaken"]=self.actionsTaken;
    viewFeedback[@"timeViewed"]=[NSNumber numberWithFloat:self.secondsViewed];
    
    [viewFeedback saveInBackground];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType != UIWebViewNavigationTypeOther){
        return NO;
    }
    else{
        return YES;
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    if (self.loadingCount==0){
        //add the activity indicator
        UIActivityIndicatorView * loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.momentWebView.frame.size.width/2-20, 240, 40, 40)];
        loadingIndicator.backgroundColor=[UIColor darkGrayColor];
        loadingIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
        loadingIndicator.layer.cornerRadius=8;
        loadingIndicator.tag=67;
        [self.momentWebView addSubview:loadingIndicator];
    }
    self.loadingCount++;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.loadingCount--;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.loadingCount--;
    
    if (self.loadingCount==0){
        //remove the activity indicator
        [[self.momentWebView viewWithTag:67] removeFromSuperview];
    }
}

@end