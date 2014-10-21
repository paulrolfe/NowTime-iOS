//
//  CustomView.h
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@protocol NTCustomViewDelegate;

@interface NTCustomView : UIView <UIGestureRecognizerDelegate>

//------------------------------------------------------------------------------------//
//----- DELEGATE ---------------------------------------------------------------------//
//------------------------------------------------------------------------------------//


/** The object that acts as delegate to the custom view
 
 @abstract The custom view delegate receives things like when a gesture finishes.
 @discussion The delegate must adopt the NTCustomViewDelegate protocol. The delegate is not retained.*/
@property (nonatomic, assign) IBOutlet id <NTCustomViewDelegate> delegate;

@property (weak, nonatomic) UIWebView * webview;
@property (weak, nonatomic) UIWebView * nextWebview;

@property BOOL backAllowed;
-(void) addGestures;
-(void)fadeawayWebView:(UIView *)webview toNext:(BOOL)next;


@end
CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2);


@protocol NTCustomViewDelegate <NSObject>

@optional

//----- TOUCH EVENTS -----//

/** Sent to the delegate when the user has let go of the next swipe*/
- (void) customViewReadyForNextMoment;
/** Sent to the delegate when the user has let go of the back swipe*/
- (void) customViewReadyForPreviousMoment;
/** Sent to the delegate when the user has tapped*/
- (void) customViewWasTapped;
/** Sent to the delegate when the webview has been dragged to the left*/
- (void) customViewPannedToLeft;
/** Sent to the delegate when the webview has been dragged to the right*/
- (void) customViewPannedToRight;



@end
