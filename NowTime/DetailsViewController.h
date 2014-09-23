//
//  DetailsViewController.h
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentObject.h"
#import "UploadViewController.h"
#import <Social/Social.h>

@class MomentObject;

@interface DetailsViewController : UIViewController{
    CGRect originalFrame;
}
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *clipboardButton;
- (IBAction)clipboardAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)uploadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *fbShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twShareButton;
@property (weak, nonatomic) IBOutlet UIButton *googShareButton;
@property (weak, nonatomic) IBOutlet UIButton *pintShareButton;
@property (weak, nonatomic) IBOutlet UIButton *tumblrShareButton;

- (IBAction)fbShareAction:(id)sender;
- (IBAction)twShareAction:(id)sender;
- (IBAction)googShareAction:(id)sender;
- (IBAction)pintShareAction:(id)sender;
- (IBAction)tumblrShareAction:(id)sender;

-(void)animateViewUp:(BOOL)up;
@property UIView * containerView;
@property UIViewController * mainViewController;
@property (weak, nonatomic) MomentObject * currentMoment;

@end
