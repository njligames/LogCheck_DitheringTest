//
//  ViewController.m
//  Created on 12/18/18.
//

#import "ViewController.h"

typedef NS_ENUM(NSInteger, DitheringAlgorithm) {
    DitheringAlgorithmFloydSteinberg = 0,
    DitheringAlgorithmSierra3,
    DitheringAlgorithmJarvisJudiceNinke
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

    CGRect imageBounds = CGRectIntegral(targetBounds);

    [self.activityIndicatorView startAnimating];
    [self.chooseImageButton setEnabled:NO];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        size_t width = imageBounds.size.width;
        size_t height = imageBounds.size.height;

        // To fill pixelBuffer with a grayscale version of the original image,
        // we create a bitmap context around it, and then use Core Graphics to
        // draw the image.

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width, height,
                                                     8, // bitsPerComponent
                                                     width, // bytesPerRow
                                                     colorSpace,
                                                     kCGImageAlphaNone);

        CGContextDrawImage(context, imageBounds, [originalImage CGImage]);

        CGColorSpaceRelease(colorSpace);

        // Next, we scan our pixelBuffer, line by line, filling up the
        // ditheredPixelBuffer with a black-and-white version. We use the
        // errorBuffer to store the error values that we are diffusing to
        // later pixels, according to the selected error diffusion algorithm.

        UInt8 *pixelBuffer = CGBitmapContextGetData(context);
        UInt8 *ditheredPixelBuffer = malloc(width * height);
        SInt8 *errorBuffer = calloc(width * height, sizeof(SInt8));

        for (size_t y = 0; y < height; y++) {
            for (size_t x = 0; x < width; x++) {
                size_t xy = x + (y * width);
                UInt8 oldPixel = pixelBuffer[xy];
                UInt8 newPixel = (oldPixel + errorBuffer[xy]) < 0x80 ? 0x00 : 0xFF;

                switch (self->_selectedAlgorithm) {
                    case DitheringAlgorithmFloydSteinberg: {
                        // Error Diffusion Pattern:
                        // ....  XXXX  7/16
                        // 3/16  5/16  1/16
                        SInt16 error_16 = (oldPixel - newPixel) / 16;
                        if (x + 1 < width) errorBuffer[xy + 1] += 7 * error_16;
                        if (y + 1 < height) {
                            if (x > 0) errorBuffer[xy + width - 1] += 3 * error_16;
                            errorBuffer[xy + width] += 5 * error_16;
                            if (x + 1 < width) errorBuffer[xy + width + 1] += 1 * error_16;
                        }
                        break;
                    }

                    case DitheringAlgorithmJarvisJudiceNinke: {
                        // Error Diffusion Pattern:
                        // ....  ....  XXXX  7/48  5/48
                        // 3/48  5/48  7/48  5/48  3/48
                        // 1/48  3/48  5/48  3/48  1/48
                        SInt16 error_48 = (oldPixel - newPixel) / 48;
                        if (x + 1 < width) errorBuffer[xy + 1] += 7 * error_48;
                        if (x + 2 < width) errorBuffer[xy + 2] += 5 * error_48;
                        if (y + 1 < height) {
                            if (x > 1) errorBuffer[xy + width - 2] += 3 * error_48;
                            if (x > 0) errorBuffer[xy + width - 1] += 5 * error_48;
                            errorBuffer[xy + width] += 7 * error_48;
                            if (x + 1 < width) errorBuffer[xy + width + 1] += 5 * error_48;
                            if (x + 2 < width) errorBuffer[xy + width + 2] += 3 * error_48;
                        }
                        if (y + 2 < height) {
                            if (x > 1) errorBuffer[xy + (2 * width) - 2] += 1 * error_48;
                            if (x > 0) errorBuffer[xy + (2 * width) - 1] += 3 * error_48;
                            errorBuffer[xy + (2 * width)] += 5 * error_48;
                            if (x + 1 < width) errorBuffer[xy + (2 * width) + 1] += 3 * error_48;
                            if (x + 2 < width) errorBuffer[xy + (2 * width) + 2] += 1 * error_48;
                        }
                        break;
                    }

                    case DitheringAlgorithmSierra3: {
                        // Error Diffusion Pattern:
                        // ....  ....  XXXX  5/32  3/32
                        // 2/32  4/32  5/32  4/32  2/32
                        // ....  2/32  3/32  2/32  ....
                        SInt16 error_32 = (oldPixel - newPixel) / 32;
                        if (x + 1 < width) errorBuffer[xy + 1] += 5 * error_32;
                        if (x + 2 < width) errorBuffer[xy + 2] += 3 * error_32;
                        if (y + 1 < height) {
                            if (x > 1) errorBuffer[xy + width - 2] += 2 * error_32;
                            if (x > 0) errorBuffer[xy + width - 1] += 4 * error_32;
                            errorBuffer[xy + width] += 5 * error_32;
                            if (x + 1 < width) errorBuffer[xy + width + 1] += 4 * error_32;
                            if (x + 2 < width) errorBuffer[xy + width + 2] += 2 * error_32;
                        }
                        if (y + 2 < height) {
                            if (x > 0) errorBuffer[xy + (2 * width) - 1] += 2 * error_32;
                            errorBuffer[xy + (2 * width)] += 3 * error_32;
                            if (x + 1 < width) errorBuffer[xy + (2 * width) + 1] += 2 * error_32;
                        }
                        break;
                    }

                    default:
                        break;
                }

                ditheredPixelBuffer[xy] = newPixel;
            }
        }

        // Finally, we convert our ditheredPixelBuffer into a CGImage, which
        // can be used to create a UIImage, which can be displayed in a
        // UIImageView.

        CFDataRef pixelData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                          ditheredPixelBuffer,
                                                          width * height,
                                                          kCFAllocatorMalloc);
        CGDataProviderRef pixelDataProvider = CGDataProviderCreateWithCFData(pixelData);
        CGImageRef image = CGImageCreate(width, height,
                                         8, 8, width,
                                         colorSpace,
                                         (CGBitmapInfo)kCGImageAlphaNone,
                                         pixelDataProvider,
                                         NULL,
                                         false,
                                         kCGRenderingIntentDefault);

        UIImage *ditheredImage = [UIImage
                                  imageWithCGImage:image
                                  scale:1.0
                                  orientation:originalImage.imageOrientation];

        CGImageRelease(image);
        CGDataProviderRelease(pixelDataProvider);
        CFRelease(pixelData);

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
                default:
                    [self.algorithmLabel setText:@"Unknown"];
                    break;
            }
        });
    });
}

@end
