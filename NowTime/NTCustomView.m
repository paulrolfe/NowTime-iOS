//
//  CustomView.m
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import "NTCustomView.h"

@implementation NTCustomView{
    CGPoint lastViewPosition;
    CGPoint grabAnchor;
    CGRect oldframe;
    UITapGestureRecognizer * tap;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}
-(void) addGestures{
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate=self;
    tap.delegate=self;
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    /*if (gestureRecognizer==tap)
        return YES;
    else*/
        return NO;
}
-(void)setWebview:(UIWebView *)webview{
    _webview=webview;
    _webview.frame=self.frame;
    _webview.scalesPageToFit=YES;
    [self addSubview:_webview];
}
-(void)setNextWebview:(UIWebView *)nextWebview{
    _nextWebview=nextWebview;
    _nextWebview.frame=self.frame;
    [self insertSubview:_nextWebview belowSubview:self.webview];
}

-(void) handlePan:(UIPanGestureRecognizer *)gestureRecognizer{
    CGRect newframe = self.webview.frame;
    CGPoint translation = [gestureRecognizer locationInView:self.viewForBaselineLayout];
    //set the anchor point
    if (gestureRecognizer.state==UIGestureRecognizerStateBegan){
        grabAnchor = translation;
        oldframe = self.webview.frame;
    }
    else if (gestureRecognizer.state==UIGestureRecognizerStateChanged){
        newframe.origin.x = translation.x - grabAnchor.x;
        newframe.origin.y = translation.y - grabAnchor.y;
        self.webview.frame = newframe;
        
        if (newframe.origin.x>oldframe.origin.x && lastViewPosition.x<=oldframe.origin.x)
            [self.delegate customViewPannedToRight];
        if (newframe.origin.x<oldframe.origin.x && lastViewPosition.x>=oldframe.origin.x)
            [self.delegate customViewPannedToLeft];
        
        lastViewPosition=newframe.origin;
    }
    else if (gestureRecognizer.state==UIGestureRecognizerStateEnded){
        if (grabAnchor.x>translation.x+80){//Next
            [self fadeawayWebView:self.webview toNext:YES];
        }
        else if (grabAnchor.x<translation.x-80 && self.backAllowed){//Last
            [self fadeawayWebView:self.webview toNext:NO];
        }
        else{//Return
            [UIView animateWithDuration:.2 delay:0 options:0 animations:^{
                // Animate the alpha value of your imageView from 1.0 to 0.0 here
                self.webview.frame = oldframe;

            } completion:^(BOOL finished) {
                //Show a popup that you can only go back once.
                if (!self.backAllowed){
                    UIAlertView * noGo = [[UIAlertView alloc] initWithTitle:@"We're jerks" message:@"You can only go back one Moment. But that's ok, don't dwell in the past, on to the next one!" delegate:nil cancelButtonTitle:@"Yes, onward!" otherButtonTitles: nil];
                    [noGo show];
                }
                
            }];
        }
    }
}
- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer{
    //if the tap wasn't clicking a link...
    [self.delegate customViewWasTapped];
}
-(void)fadeawayWebView:(UIView *)webview toNext:(BOOL)next{
    CGRect newFrame;
    if(next){
        newFrame=CGRectMake(-self.frame.size.width, webview.frame.origin.y, self.frame.size.width,self.frame.size.height);
    }
    else{
        newFrame=CGRectMake(self.frame.size.width, webview.frame.origin.y, self.frame.size.width,self.frame.size.height);
    }
    
    [UIView animateWithDuration:.1 delay:0 options:0 animations:^{
        webview.frame = newFrame;
    } completion:^(BOOL finished) {
        [webview removeFromSuperview];
        if(next)
            [self.delegate customViewReadyForNextMoment];
        else
            [self.delegate customViewReadyForPreviousMoment];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
	CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
