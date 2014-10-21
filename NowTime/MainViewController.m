//
//  ViewController.m
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize contentContainer,detailsContainer,detailsController,momentQueue;

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden=YES;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [contentContainer addGestures];
    contentContainer.delegate=self;
    detailsContainer.hidden=YES;
    
    //load an array of moments
    momentQueue = [[NSMutableArray alloc] init];
    for (int i = 0;i<5;i++){
        //[self performSelector:@selector(loadNewMoment) withObject:nil afterDelay:i];
        [self loadNewMoment];
        NSLog(@"Loaded moment %d",i);
    }
    momentFrame=contentContainer.frame;
    self.currentMoment = momentQueue[0];
    contentContainer.webview=self.currentMoment.momentWebView;
    contentContainer.nextWebview=[(MomentObject *)momentQueue[1] momentWebView];
    [self.loadImageView removeFromSuperview];
    
    self.contentContainer.backAllowed=NO;
    self.lastButtonView.enabled=NO;
    
    //Hide the status bar.
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{

}
-(void) viewDidAppear:(BOOL)animated{

}
-(void) viewWillDisappear:(BOOL)animated{
    //[self.currentMoment pauseTimer];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) loadNewMoment{
    MomentObject * momentGetter = [[MomentObject alloc] init];
    [momentQueue addObject: [momentGetter fetchNewObject]];
}
-(void) setCurrentMoment:(MomentObject *)currentMoment{
    
    //end the timer on the current object.
    [self.currentMoment pauseTimer];
    
    //make the new object current.
    _currentMoment=currentMoment;
    contentContainer.webview=self.currentMoment.momentWebView;
    detailsController.currentMoment=self.currentMoment;

    
    //tell the object to start a timer.
    [self.currentMoment startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self restartSession];
    } 
}
-(IBAction)restartSession
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset?" message:@"If you want us to forget you what you've seen so far click Reset." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset",nil];
    alertView.tag=1;
    [alertView show];
}
#pragma mark - custom view delegate
-(void)customViewReadyForNextMoment{
    
    if (self.contentContainer.backAllowed==YES){ //if we're on index 1...
        self.currentMoment = momentQueue[2];
        //release moment at index 0. (formerly the previous moment)
        [(MomentObject *)momentQueue[0] sendFeedback];
        [momentQueue removeObjectAtIndex:0];
        //load new moment into index 5. (the 4th moment to be shown next)
        [self loadNewMoment];
    }
    if (self.contentContainer.backAllowed!=YES) //if we're on index 0...
        self.currentMoment = momentQueue[1];
    NSLog(@"New url is: %@",self.currentMoment.url);
    
    contentContainer.nextWebview=[(MomentObject *)momentQueue[2] momentWebView];
    
    self.contentContainer.backAllowed=YES;
    self.lastButtonView.enabled=YES;

}
-(void)customViewReadyForPreviousMoment{
    
    self.currentMoment = momentQueue[0];
    NSLog(@"Old url is: %@",self.currentMoment.url);
    
    contentContainer.nextWebview=[(MomentObject *)momentQueue[1] momentWebView];
    
    self.contentContainer.backAllowed=NO;
    self.lastButtonView.enabled=NO;
}
-(void)customViewWasTapped{
    //only using the tap to bring down the menu for now.
    if (detailsContainer.hidden==YES){
        detailsContainer.hidden=NO;
        detailsController.currentMoment=self.currentMoment;
        [detailsController animateViewUp:YES];
    }
    else
        [detailsController animateViewUp:NO];
}
-(void)customViewPannedToLeft{
    if(self.contentContainer.backAllowed){ //Show the NEXT moment underneath (index 2)
        contentContainer.nextWebview=[(MomentObject *)momentQueue[2] momentWebView];
    }
    else{ //show the moment you just went back FROM (index 1)
        contentContainer.nextWebview=[(MomentObject *)momentQueue[1] momentWebView];

    }
}
-(void)customViewPannedToRight{ //show the last moment underneath if it exists
    if(self.contentContainer.backAllowed){
        contentContainer.nextWebview=[(MomentObject *)momentQueue[0] momentWebView];
    }
}

- (IBAction)nextButton:(id)sender {
    [self.contentContainer fadeawayWebView:contentContainer.webview toNext:YES];
}

- (IBAction)lastButton:(id)sender {
    [self customViewPannedToRight];
    [self.contentContainer fadeawayWebView:contentContainer.webview toNext:NO];
}

- (IBAction)infoButton:(id)sender {
    [self customViewWasTapped];
}
-(void)dismissContainer{
    [detailsController animateViewUp:NO];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"embedSegue"]) {
        self.detailsController = segue.destinationViewController;
        self.detailsController.mainViewController=self;

        [self.detailsController setContainerView:self.detailsContainer];
  
    }
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1 && alertView.tag==1){//They want a reset.
        [self resetUserSession];
    }
}
-(void) resetUserSession{
    //For now, we just erase their viewedMoments Relation.
    [PFUser logOut];
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackground];
    
}
@end
