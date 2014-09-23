//
//  ViewController.h
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentObject.h"
#import "NTCustomView.h"
#import "DetailsViewController.h"

@class DetailsViewController;
@class MomentObject;

@interface MainViewController : UIViewController <UIWebViewDelegate,NTCustomViewDelegate>{
    CGRect momentFrame;
}

@property (weak, nonatomic) IBOutlet UIView *detailsContainer;
@property DetailsViewController * detailsController;
@property (weak, nonatomic) IBOutlet NTCustomView *contentContainer;
@property (weak, nonatomic) MomentObject * currentMoment;
@property NSMutableArray * momentQueue;
- (IBAction)nextButton:(id)sender;
- (IBAction)lastButton:(id)sender;
- (IBAction)infoButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lastButtonView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButtonView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *loadImageView;

@end
