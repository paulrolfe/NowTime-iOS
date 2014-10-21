//
//  UploadViewController.m
//  NowTime
//
//  Created by Paul Rolfe on 9/1/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import "UploadViewController.h"

@interface UploadViewController ()

@end

@implementation UploadViewController

@synthesize headlineField, imageUploadButton, textView, uploadButton, uploadedImage;

UIView *firstResponder;
CGRect originalFrame;


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
    headlineField.delegate=self;
    textView.delegate=self;
    textView.layer.cornerRadius=8;
    imageUploadButton.layer.cornerRadius=8;
    uploadedImage.contentMode=UIViewContentModeScaleAspectFit;

}
-(void)viewWillAppear:(BOOL)animated{
    
    // Register notifications for when the keyboard appears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    firstResponder=textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    firstResponder=nil;
}
-(void)textViewDidBeginEditing:(UITextView *)textViewInstance{
    firstResponder=textViewInstance;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==headlineField){
        [headlineField resignFirstResponder];
        [self imageUploadAction:nil];
    }
    return YES;
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

- (IBAction)uploadAction:(id)sender {
    if(headlineField.text!=nil && uploadedImage.image!=nil && textView.text!=nil){
        PFObject * newMedia = [PFObject objectWithClassName:@"Media"];
        newMedia[@"type"]=@"image";
        newMedia[@"text"]=textView.text;
        
        UIImage * resizedImage = [self resizeProfileImage];
        NSData * imageData = UIImagePNGRepresentation(resizedImage);
        PFFile *userImageFile = [PFFile fileWithData:imageData];
        [newMedia setObject:userImageFile forKey:@"image"];
        
        UIActivityIndicatorView * waiting = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2, 100, 100)];
        waiting.tag=3;
        waiting.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        [waiting startAnimating];
        [self.view addSubview:waiting];
        
        //first save the media
        [newMedia saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                
                //then save the moment with the media as a relation.
                PFObject * newMoment = [PFObject objectWithClassName:@"Moment"];
                PFRelation * mediaRelation = [newMoment relationForKey:@"mediaObjects"];
                [mediaRelation addObject:newMedia];
                newMoment[@"headline"]=headlineField.text;
                
                [newMoment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        //Set up the MainViewController to display this new moment as the current moment.
                        MomentObject * justUploaded = [[MomentObject alloc] initWithObject:newMoment];
                        [(MainViewController *)self.mainViewController setCurrentMoment:justUploaded];
                        [self backAction:nil];
                    }
                    else{
                        NSLog(@"Error");
                        [[self.view viewWithTag:3] removeFromSuperview];
                        [self backAction:nil];
                        UIAlertView * errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your moment is stuck in cyber space. Give it another try." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [errorView show];
                    }
                }];
                NSLog(@"SAVED THAT NEW MOMENT");
            }
            else{
                NSLog(@"Error");
                [[self.view viewWithTag:3] removeFromSuperview];
                [self backAction:nil];
                UIAlertView * errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your moment is stuck in cyber space. Give it another try." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorView show];
            }
        }];
        
    }
    else{
        UIAlertView * needsURL = [[UIAlertView alloc] initWithTitle:@"Empty Fields" message:@"Please enter a headline, image and some text to share." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [needsURL show];
    }
    
}
- (IBAction)backAction:(id)sender {
    if (firstResponder)
        [firstResponder resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)imageUploadAction:(id)sender{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    // Don't forget to add UIImagePickerControllerDelegate in your .h
    picker.delegate = self;
    
    if((UIButton *) sender == uploadButton) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //put the photo in the image.
    UIImage * newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    uploadedImage.image = newImage;
    [self.view reloadInputViews];
    //close the pickerview
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //close the pickerview
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(UIImage *) resizeProfileImage{
    CGFloat realHeight = uploadedImage.image.size.height;
    CGFloat realWidth = uploadedImage.image.size.width;
    CGFloat newWidth = 720;
    CGFloat newHeight = (newWidth * realHeight)/realWidth;
    
    CGSize newSize=CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext( newSize );
    [uploadedImage.image drawInRect:CGRectMake(0,0,newWidth,newHeight)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (IBAction)dismissKeyboard:(id)sender {
    if (firstResponder)
        [firstResponder resignFirstResponder];
}

//keyboard handlers from http://astralbodies.net/blog/2012/02/01/resizing-a-uitextview-automatically-with-the-keyboard/
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)keyboardWillShow:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:NO];
    
}
- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    if (firstResponder!=headlineField)
        firstResponder=textView;
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat desiredRectOrigin = keyboardRect.origin.y;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (up == YES) {
        CGRect newFrame = self.view.frame;
        originalFrame=self.view.frame;
        
        if (firstResponder.frame.origin.y+firstResponder.frame.size.height>desiredRectOrigin){//something that says whether the textfield is below the keyboard.
            newFrame.origin.y = -((firstResponder.frame.origin.y+firstResponder.frame.size.height)-desiredRectOrigin);
            [self.view setFrame:newFrame];
        }
    } else {
        
        // Keyboard is going away (down) - restore original frame
        [self.view setFrame:originalFrame];
    }
    
    [UIView commitAnimations];
    
}


@end
