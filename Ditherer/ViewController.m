//
//  ViewController.m
//  Created on 12/18/18.
//

#import "ViewController.h"

#import "Algorithms/FloydSteinbergDitherer.h"
#import "Algorithms/JarvisJudiceNinkeDitherer.h"
#import "Algorithms/Sierra3Ditherer.h"
#import "Algorithms/AtkinsonDitherer.h"

typedef NS_ENUM(NSInteger, DitheringAlgorithm) {
    DitheringAlgorithmFloydSteinberg = 0,
    DitheringAlgorithmSierra3,
    DitheringAlgorithmJarvisJudiceNinke,
    DitheringAlgorithmAtkinson
};

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation ViewController
{
    DitheringAlgorithm _selectedAlgorithm;
}

// MARK: UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// MARK: Button Actions

- (IBAction)chooseImage:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [picker setDelegate:self];

    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)chooseAlgorithm:(UIButton *)sender
{
    UIAlertController *menu = [UIAlertController
                               alertControllerWithTitle:nil
                               message:nil
                               preferredStyle:UIAlertControllerStyleActionSheet];

    menu.popoverPresentationController.sourceView = sender;

    [menu addAction:[UIAlertAction
                     actionWithTitle:@"Floyd-Steinberg (1976)"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * _Nonnull action) {
                         self->_selectedAlgorithm = DitheringAlgorithmFloydSteinberg;
                         [self dither];
                     }]];

    [menu addAction:[UIAlertAction
                     actionWithTitle:@"Jarvis, Judice, and Ninke (1976)"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * _Nonnull action) {
                         self->_selectedAlgorithm = DitheringAlgorithmJarvisJudiceNinke;
                         [self dither];
                     }]];

    [menu addAction:[UIAlertAction
                     actionWithTitle:@"Sierra (1989)"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * _Nonnull action) {
                         self->_selectedAlgorithm = DitheringAlgorithmSierra3;
                         [self dither];
                     }]];
    
    [menu addAction:[UIAlertAction
                     actionWithTitle:@"Atkinson (1984)"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * _Nonnull action) {
                         self->_selectedAlgorithm = DitheringAlgorithmAtkinson;
                         [self dither];
                     }]];

    [menu addAction:[UIAlertAction
                     actionWithTitle:@"Cancel"
                     style:UIAlertActionStyleCancel
                     handler:nil]];

    [self presentViewController:menu animated:YES completion:nil];
}

// MARK: UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    self.originalImageView.image = image;

    [self dismissViewControllerAnimated:YES completion:^{
        [self dither];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: Dithering

- (void)dither
{
    UIImage *originalImage = self.originalImageView.image;

    // To determine the bounds of the image we are creating, we start with the
    // bounds of the target image view. This will make pixels aligned with the
    // display, which looks nice. Then, we adjust that rectangle to match the
    // aspect ratio of the original image, so that it doesn't appear squished
    // or stretched.

    CGRect targetBounds = self.ditheredImageView.bounds;
    CGFloat originalAspectRatio = originalImage.size.width / originalImage.size.height;
    CGFloat targetAspectRatio = targetBounds.size.width / targetBounds.size.height;

    if (originalAspectRatio < targetAspectRatio) {
        targetBounds.size.width = targetBounds.size.height * originalAspectRatio;
    } else {
        targetBounds.size.height = targetBounds.size.width / originalAspectRatio;
    }
    
    [self.activityIndicatorView startAnimating];
    [self.chooseImageButton setEnabled:NO];

    __block UIImage *ditheredImage = nil;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
        switch (self->_selectedAlgorithm) {
            case DitheringAlgorithmFloydSteinberg: {
                ditheredImage = [FloydSteinbergDitherer dither:originalImage targetBounds:targetBounds];
                break;
            }
                
            case DitheringAlgorithmJarvisJudiceNinke: {
                ditheredImage = [JarvisJudiceNinkeDitherer dither:originalImage targetBounds:targetBounds];
                break;
            }
                
            case DitheringAlgorithmSierra3: {
                ditheredImage = [Sierra3Ditherer dither:originalImage targetBounds:targetBounds];
                break;
            }
                
            case DitheringAlgorithmAtkinson: {
                ditheredImage = [AtkinsonDitherer dither:originalImage targetBounds:targetBounds];
                break;
            }
                
            default:
                ditheredImage = [Ditherer dither:originalImage targetBounds:targetBounds];
                break;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.ditheredImageView.image = ditheredImage;
            [self.activityIndicatorView stopAnimating];
            [self.chooseImageButton setEnabled:YES];
            switch (self->_selectedAlgorithm) {
                case DitheringAlgorithmFloydSteinberg:
                    [self.algorithmLabel setText:@"Floyd-Steinberg (1976)"];
                    break;
                case DitheringAlgorithmJarvisJudiceNinke:
                    [self.algorithmLabel setText:@"Jarvis, Judice, and Ninke (1976)"];
                    break;
                case DitheringAlgorithmSierra3:
                    [self.algorithmLabel setText:@"Sierra (1989)"];
                    break;
                case DitheringAlgorithmAtkinson:
                    [self.algorithmLabel setText:@"Atkinson (1984)"];
                    break;
                default:
                    [self.algorithmLabel setText:@"Unknown"];
                    break;
            }
        });
    });
}

@end
