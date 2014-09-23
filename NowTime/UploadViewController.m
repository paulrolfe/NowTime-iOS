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
CGRect originalTextViewFrame;


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
-(void)textViewDidBeginEditing:(UITextView *)textViewInstance{
    firstResponder=textViewInstance;
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
        
        [newMedia saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                PFObject * newMoment = [PFObject objectWithClassName:@"Moment"];
                PFRelation * mediaRelation = [newMoment relationForKey:@"mediaObjects"];
                [mediaRelation addObject:newMedia];
                newMoment[@"headline"]=headlineField.text;
                
                [newMoment saveInBackground];
            }
            else{
                NSLog(@"Error");
            }
        }];
        


        
        [self backAction:nil];
    }
    else{
        UIAlertView * needsURL = [[UIAlertView alloc] initWithTitle:@"Empty Fields" message:@"Please enter a headline, image and some text to share." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [needsURL show];
    }
    
}
- (IBAction)backAction:(id)sender {
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
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat desiredRectOrigin = 200;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (up == YES) {
        CGRect newTextViewFrame = self.view.frame;
        
        if (firstResponder.frame.origin.y+firstResponder.frame.size.height>desiredRectOrigin){//something that says whether the textfield is below the keyboard.
            newTextViewFrame.origin.y = -((keyboardRect.origin.y-desiredRectOrigin)+(firstResponder.frame.origin.y - keyboardRect.origin.y));//keyboard.origin.y-desiredlocation.origin.y+(oldvieworigin.y-keyboardorigin.y)
            [self.view setFrame:newTextViewFrame];
        }
    } else {
        
        // Keyboard is going away (down) - restore original frame
        [self.view setFrame:originalTextViewFrame];
    }
    
    [UIView commitAnimations];
    
}


@end
