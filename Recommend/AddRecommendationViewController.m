//
//  AddRecommendationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "AddRecommendationViewController.h"
#import "HomeViewController.h"

#define defaultTitleString @"What do you recommend?"
#define defaultDescriptionString @"Write a short description here."

@interface AddRecommendationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *cameraScrollView;
@property UITextField *activeTextField;
@property UITextView *activeTextView;
@property UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *takeAnotherButton;
@property UIImage *currentFlashImage;
@property (weak, nonatomic) IBOutlet UIButton *setLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *lineTwo;
@property (weak, nonatomic) IBOutlet UIView *lineThree;
@end

@implementation AddRecommendationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.currentFlashImage = self.flashButton.imageView.image;

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.showsCameraControls = NO;
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 27.0);
        CGAffineTransform scale = CGAffineTransformScale(translate, 1.6, 1.6);
        self.picker.cameraViewTransform = scale;
        self.picker.cameraOverlayView = self.view;

        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.picker.cameraDevice =  UIImagePickerControllerCameraDeviceRear;
        } else {
            self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }

        [self.picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
        [self.picker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];

        [self presentViewController:self.picker animated:YES completion:nil];
    }
}

- (void)showCamera
{
    self.takePictureButton.hidden = NO;
    self.cameraRollButton.hidden = NO;
    self.flashButton.hidden = NO;
    self.topLine.hidden = NO;
    self.lineTwo.hidden = NO;
    self.lineThree.hidden = NO;

    self.capturedImageView.hidden = YES;
    self.setLocationButton.hidden = YES;
    self.takeAnotherButton.hidden = YES;
}

- (void)hideCamera
{
    self.takePictureButton.hidden = YES;
    self.cameraRollButton.hidden = YES;
    self.flashButton.hidden = YES;
    self.topLine.hidden = YES;
    self.lineTwo.hidden = YES;
    self.lineThree.hidden = YES;

    self.capturedImageView.hidden = NO;
    self.setLocationButton.hidden = NO;
    self.takeAnotherButton.hidden = NO;
}

- (IBAction)onAlbumPressed:(id)sender
{
    
}

- (IBAction)onTakePhotoPressed:(id)sender
{
    [self.picker takePicture];
}

- (IBAction)onTakeAnotherPhotoPressed:(id)sender
{
    [self showCamera];
}

- (IBAction)onFlashPressed:(id)sender
{
    if (self.currentFlashImage == [UIImage imageNamed:@"flash"]) {
        [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
        self.currentFlashImage = [UIImage imageNamed:@"flash-off"];
    } else {
        [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        self.currentFlashImage = [UIImage imageNamed:@"flash"];
    }
}

- (IBAction)onCloseCameraPressed:(id)sender
{
    [self.picker dismissViewControllerAnimated:NO completion:^{
    }];
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)onSetLocationPressed:(id)sender
{
    [self.picker dismissViewControllerAnimated:NO completion:^{
    }];
    [self performSegueWithIdentifier:@"LocationSegue" sender:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];

    self.capturedImageView.image = image;

    [self hideCamera];

    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (BOOL) textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    static const NSUInteger MAX_NUMBER_OF_LINES_ALLOWED = 3;

    NSMutableString *t = [NSMutableString stringWithString:
                          self.descriptionTextView.text];
    [t replaceCharactersInRange: range withString: text];

    NSUInteger numberOfLines = 0;
    for (NSUInteger i = 0; i < t.length; i++) {
        if ([[NSCharacterSet newlineCharacterSet]
             characterIsMember: [t characterAtIndex: i]]) {
            numberOfLines++;
        }
    }

    return (numberOfLines < MAX_NUMBER_OF_LINES_ALLOWED);
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.cameraScrollView.contentInset = contentInsets;
    self.cameraScrollView.scrollIndicatorInsets = contentInsets;

    CGRect fieldFrame = self.activeTextField ? self.activeTextField.frame : self.activeTextView.frame;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = fieldFrame.origin;
    origin.y -= (self.cameraScrollView.contentOffset.y-150);
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, (fieldFrame.origin.y+150)-(aRect.size.height));
        [self.cameraScrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.cameraScrollView.contentInset = contentInsets;
    self.cameraScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqual:defaultTitleString]) {
        textField.text = @"";
    }
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqual:@""]) {
        textField.text = defaultTitleString;
    }
    self.activeTextField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqual:defaultDescriptionString]) {
        textView.text = @"";
    }
    self.activeTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@""]) {
        textView.text = defaultDescriptionString;
    }
    self.activeTextView = nil;
}

@end
