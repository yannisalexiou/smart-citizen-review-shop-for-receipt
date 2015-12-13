//
//  SelectedVenueVC.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "SelectedVenueVC.h"

@interface SelectedVenueVC ()

@property (strong, nonatomic) IBOutlet UIImageView *venueBackgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *venueImageView;
@property (strong, nonatomic) IBOutlet UILabel *venueTitle;
@property (strong, nonatomic) IBOutlet UILabel *venueSubTitle;
@property (strong, nonatomic) IBOutlet UIButton *backButtonOutlet;

- (IBAction)rateButtonPressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;

@end

@implementation SelectedVenueVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //VieController Setup
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    //Hack για ενεργοποίηση του swipe gesture
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.venueImageView.layer.cornerRadius = self.venueImageView.frame.size.width/2;
    
    [self updateUIElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateUIElements
{
    self.venueTitle.text = self.retrievedVenue.name;
    self.venueImageView.image = self.retrievedVenue.image;
    self.venueBackgroundImageView.image = self.retrievedVenue.image;
}

- (IBAction)rateButtonPressed:(UIButton *)sender
{
    
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    //[self performSegueWithIdentifier:@"selectedVenueSegue" sender:indexPath];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
