//
//  DetailsViewController.m
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

@synthesize urlLabel,uploadButton, clipboardButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer * swipeD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownHandler)];
    swipeD.direction=UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeD];
    
    originalFrame=self.containerView.frame;
    uploadButton.layer.cornerRadius=8;
    clipboardButton.layer.cornerRadius=8;
    [self animateViewUp:NO];

}
-(void)setCurrentMoment:(MomentObject *)currentMoment{
    _currentMoment=currentMoment;
    urlLabel.text=currentMoment.url.absoluteString;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) swipeDownHandler{
    [self animateViewUp:NO];
}
- (IBAction)clipboardAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=_currentMoment.url.absoluteString;
}

- (IBAction)uploadAction:(id)sender {
    UploadViewController * uvc = [self.storyboard instantiateViewControllerWithIdentifier:@"uploader"];
    uvc.mainViewController=self.mainViewController;
    [self.mainViewController.navigationController pushViewController:uvc animated:YES];
}

- (IBAction)fbShareAction:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        NSLog(@"Ready to Facebook.");
        [self.currentMoment.pfObject fetchIfNeeded];
        SLComposeViewController *fbComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbComposer setInitialText:self.currentMoment.pfObject[@"headline"]];
        [fbComposer addImage:[UIImage imageNamed:@"icon1_1024"]];
        [fbComposer addURL:self.currentMoment.url];
        fbComposer.completionHandler = ^(SLComposeViewControllerResult result){
            if(result == SLComposeViewControllerResultDone){
                NSLog(@"Facebooked.");
                [self animateViewUp:NO];
                [self.currentMoment.actionsTaken addObject:kFacebookShare];

            } else if(result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled.");
            }
        };
        [self presentViewController:fbComposer animated:YES completion:nil];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"You can't facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)twShareAction:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSLog(@"Ready to  Tweet.");
        [self.currentMoment.pfObject fetchIfNeeded];
        SLComposeViewController *fbComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [fbComposer setInitialText:self.currentMoment.pfObject[@"headline"]];
        [fbComposer addImage:[UIImage imageNamed:@"icon1_1024"]];
        [fbComposer addURL:self.currentMoment.url];
        fbComposer.completionHandler = ^(SLComposeViewControllerResult result){
            if(result == SLComposeViewControllerResultDone){
                NSLog(@"tweeted.");
                [self animateViewUp:NO];
                [self.currentMoment.actionsTaken addObject:kTwitterShare];
                
            } else if(result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled.");
            }
        };
        [self presentViewController:fbComposer animated:YES completion:nil];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"You can't tweet right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

- (IBAction)googShareAction:(id)sender {
}

- (IBAction)pintShareAction:(id)sender {
}

- (IBAction)tumblrShareAction:(id)sender {
}

-(void)animateViewUp:(BOOL)up{
    if (up){
        //load the details
        
        //animate up
        [UIView animateWithDuration:.2 delay:0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.containerView.frame=originalFrame;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }
    else{
        //animate down
        [UIView animateWithDuration:.2 delay:0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.containerView.frame=CGRectMake(0,originalFrame.origin.y+originalFrame.size.height,originalFrame.size.width, originalFrame.size.height);
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
            [self.containerView setHidden:YES];
        }];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
