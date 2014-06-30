//
//  AddRecommendationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "AddRecommendationViewController.h"
#import "LocationViewController.h"
#import "TabBarViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"

#define defaultTitleString @"What do you recommend?"
#define defaultDescriptionString @"Write a short description here."
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface AddRecommendationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,FBLoginViewDelegate, NSLayoutManagerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *cameraScrollView;
@property AVCaptureSession *captureSession;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureDevice *device;
@property AVCaptureFlashMode flashMode;
@property UIImagePickerController *picker;
@property UIImagePickerController *imageRollPicker;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *takeAnotherButton;
@property UIImage *currentFlashImage;
@property (weak, nonatomic) IBOutlet UIButton *setLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *lineTwo;
@property (weak, nonatomic) IBOutlet UIView *lineThree;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingCameraLabel;
@property (weak, nonatomic) IBOutlet UIView *continueButtonsView;
@property (weak, nonatomic) IBOutlet UIView *cameraControlsView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraRollPreview;
@end

@implementation AddRecommendationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.descriptionTextView.layoutManager.delegate = self;

    for (UIView *subview in self.cameraScrollView.subviews) {
        subview.layer.shadowColor = [[UIColor blackColor] CGColor];
        subview.layer.shadowOffset = CGSizeMake(0.8f, 0.8f);
        subview.layer.shadowOpacity = 0.6f;
        subview.layer.shadowRadius = 0.6f;
        }

    [self setLatestImageOffAlbum];

    self.currentFlashImage = self.flashButton.imageView.image;

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];


 }

- (void)viewDidAppear:(BOOL)animated
{
//    if (FBSession.activeSession.isOpen == YES){
//
//        [FBSession openActiveSessionWithAllowLoginUI:NO];

    [super viewDidAppear:animated];

    if (!self.captureSession) {
        [self setupCaptureSession];
    }

    [self showCameraControls];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [FBSession openActiveSessionWithAllowLoginUI:NO];

    if (FBSession.activeSession.isOpen == YES) {


    self.capturedImageView.image = nil;
    self.cameraScrollView.alpha = 0;

    [self.view setBackgroundColor: RGB(2, 156, 188)];

    [self.setLocationButton.layer setBorderWidth:1.0];
    [self.setLocationButton.layer setCornerRadius:5];
    [self.setLocationButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];

    [self.takeAnotherButton.layer setBorderWidth:1.0];
    [self.takeAnotherButton.layer setCornerRadius:5];
    [self.takeAnotherButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];

    self.loadingCameraLabel.hidden = NO;
    self.videoPreviewView.hidden = YES;

    [self.navigationController setNavigationBarHidden:YES];
    [(TabBarViewController *)self.tabBarController setTabBarVisible:NO animated:YES];
    }
    else{

        [self performSegueWithIdentifier:@"loginSegue" sender:self];

    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [(TabBarViewController *)self.tabBarController setTabBarVisible:YES animated:YES];
}

- (void)showCameraControls
{
    [UIView animateWithDuration:0.2 animations:^{
        self.warningLabel.alpha = 0.0;
    }];

    if (self.captureSession) {
        [self.captureSession startRunning];
        self.videoPreviewView.hidden = NO;
        self.loadingCameraLabel.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.cameraScrollView.alpha = 1;
        }];
    }

    self.capturedImageView.hidden = YES;
    self.cameraControlsView.hidden = NO;
    self.continueButtonsView.hidden = YES;
}

- (void)hideCameraControls
{
    self.capturedImageView.hidden = NO;
    self.cameraControlsView.hidden = YES;
    self.continueButtonsView.hidden = NO;
}

- (IBAction)onAlbumPressed:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {

        [self.picker dismissViewControllerAnimated:NO completion:^{
        }];
        
        self.imageRollPicker = [[UIImagePickerController alloc] init];
        self.imageRollPicker.allowsEditing = YES;
        self.imageRollPicker.delegate = self;
        self.imageRollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:self.imageRollPicker animated:YES completion:nil];
    }
}

- (IBAction)onTakePhotoPressed:(id)sender
{
    if (self.captureSession) {
        [self captureNow];
    } else {
        [self.picker takePicture];
    }
    [self hideCameraControls];
}

- (IBAction)onTakeAnotherPhotoPressed:(id)sender
{
    self.capturedImageView.image = nil;
    [self showCameraControls];
}

- (IBAction)onFlashPressed:(id)sender
{
    if (self.currentFlashImage == [UIImage imageNamed:@"flash"]) {
        self.flashMode = AVCaptureFlashModeOff;
        [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
        self.currentFlashImage = [UIImage imageNamed:@"flash-off"];
    } else {
        self.flashMode = AVCaptureFlashModeOn;
        [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        self.currentFlashImage = [UIImage imageNamed:@"flash"];
    }
}

- (IBAction)onCloseCameraPressed:(UIButton *)sender
{
    if (self.picker) {
        [self.picker dismissViewControllerAnimated:NO completion:^{
        }];
    }
    [self.tabBarController setSelectedIndex:0];
    [self.captureSession stopRunning];
}

- (IBAction)onSetLocationPressed:(id)sender
{
    if ([self.recommendationTextField.text isEqualToString:defaultTitleString] || [self.recommendationTextField.text isEqualToString:defaultDescriptionString]) {
        [UIView animateWithDuration:1.0 animations:^{
            self.warningLabel.alpha = 1.0;
        }];
    } else {
        if (self.captureSession) {
            [self.captureSession stopRunning];
        } else {
            [self.picker dismissViewControllerAnimated:NO completion:^{
            }];
        }
        [self performSegueWithIdentifier:@"LocationSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:@"loginSegue"]) {

    LocationViewController *vc = segue.destinationViewController;
    NSMutableDictionary *recommendation = [[NSMutableDictionary alloc] initWithObjects:@[self.recommendationTextField.text, self.descriptionTextView.text, self.capturedImageView.image] forKeys:@[@"title", @"description", @"file"]];
    vc.recommendation = recommendation;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
   // NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];

    self.capturedImageView.image = image;

    [self hideCameraControls];

    if (!self.captureSession) {
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
    }
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

    CGRect fieldFrame = self.descriptionTextView.frame;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = textField.text;
    text = [text stringByReplacingCharactersInRange:range withString:string];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:textField.font}];

    return ((textSize.width+5) < textField.bounds.size.width) ? YES : NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqual:defaultTitleString]) {
        textField.text = @"";
        [UIView animateWithDuration:0.2 animations:^{
            self.warningLabel.alpha = 0.0;
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqual:@""]) {
        textField.text = defaultTitleString;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqual:defaultDescriptionString]) {
        textView.text = @"";
        [UIView animateWithDuration:0.2 animations:^{
            self.warningLabel.alpha = 0.0;
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.contentSize.height > 100)
    {
        textView.text = [textView.text substringToIndex:textView.text.length - 1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@""]) {
        textView.text = defaultDescriptionString;
    }
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 14;
}

- (void)setLatestImageOffAlbum
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];

        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {

            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                self.cameraRollPreview.image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
            }
        }];
    } failureBlock: ^(NSError *error) {

    }];
}

#pragma mark - image capture

- (void)setupImagePicker
{
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

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;

    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPreset1280x720;

    // Find a suitable AVCaptureDevice
    self.device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];

    [self setFlashMode:AVCaptureFlashModeOff forDevice:self.device];

    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device
                                                                        error:&error];
    if (!input)
    {
        [self setupImagePicker];
    }

    [session addInput:input];

    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];

    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];

    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
    [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];

    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.

    // Start the session running to start the flow of data
    [session startRunning];

    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.stillImageOutput automaticallyEnablesStillImageStabilizationWhenAvailable];

    [session addOutput:self.stillImageOutput];

    // Assign session to an ivar.
    [self setSession:session];

    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    UIView *aView = self.videoPreviewView;
    CGRect videoRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    previewLayer.frame = videoRect; // Assume you want the preview layer to fill the view.
    [aView.layer addSublayer:previewLayer];

}

-(IBAction)captureNow
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    // Set flash mode
    if (self.flashMode == AVCaptureFlashModeOff) {
        [self setFlashMode:AVCaptureFlashModeOff forDevice:self.device];
    } else {
        [self setFlashMode:AVCaptureFlashModeOn forDevice:self.device];
    }

    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:self.videoPreviewView.window.bounds];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.videoPreviewView.window addSubview:flashView];

    float flashDuration = self.flashMode == AVCaptureFlashModeOff ? 0.6f : 1.5f;

    [UIView animateWithDuration:flashDuration
                     animations:^{
                         flashView.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];

         self.capturedImageView.image = image;

         [self.captureSession stopRunning];

         [self setFlashMode:AVCaptureFlashModeOff forDevice:self.device];
     }];
}

-(void)setSession:(AVCaptureSession *)session
{
    self.captureSession=session;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            self.flashButton.hidden = YES;
            NSLog(@"%@", error);
        }
    }
}

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)sender{
    [self.tabBarController setSelectedIndex:0];
}


@end
