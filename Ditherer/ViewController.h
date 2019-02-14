//
//  ViewController.h
//  Created on 12/18/18.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UILabel *algorithmLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *ditheredImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseAlgorithmButton;

- (IBAction)chooseImage:(UIButton *)sender;
- (IBAction)chooseAlgorithm:(UIButton *)sender;

@end
