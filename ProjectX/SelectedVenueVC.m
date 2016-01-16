//
//  SelectedVenueVC.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "SelectedVenueVC.h"
#import <AdSupport/ASIdentifierManager.h>

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
    [self venueInParse]; //Store the venue in Parse
    [self userInParse]; //Store the user in Parse
    
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

-(void)userInParse
{
    NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *userId = [IDFA UUIDString];
    
    PFQuery *queryForUsers = [PFQuery queryWithClassName:kUsersClassKey];
    [queryForUsers whereKey:kUserUniqueIdKey equalTo:userId];
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            //The find succeeded.
            NSLog(@"USER SEARCH");
            if ([[objects mutableCopy] count] == 0)
            {
                PFObject *newUser = [PFObject objectWithClassName:kUsersClassKey];
                newUser[kUserUniqueIdKey] = userId;
                [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded)
                    {
                        //User stored successfully
                        NSLog(@"USER STORED");
                    }
                    else
                    {
                        //Can't store this User
                    }
                }];
            }
        }
        else
        {
            NSLog(@"Error: %@ %@, error", error, [error userInfo]);
        }
    }];
}

-(void) venueInParse
{
    PFQuery *queryForVenue = [PFQuery queryWithClassName:kVenueClassKey];
    [queryForVenue whereKey:kFoursquareVenueIdKey equalTo:self.retrievedVenue.venueId ];
    [queryForVenue findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            //The find succeeded.
            NSLog(@"VENUE SEARCH");
            
            if ([[objects mutableCopy] count] == 0)
            {
                PFObject *newVenue = [PFObject objectWithClassName:kVenueClassKey];
                newVenue[kFoursquareVenueIdKey] = self.retrievedVenue.venueId;
                [newVenue saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded)
                    {
                        //Venue stored successfully
                        NSLog(@"VENUE STORED");
                    }
                    else
                    {
                        //Can't store this Venue
                    }
                }];

            }
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    }

- (IBAction)rateButtonPressed:(UIButton *)sender
{
    
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    //[self performSegueWithIdentifier:@"selectedVenueSegue" sender:indexPath];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)negativeButtonPressed:(UIButton *)sender
{
    //Rate the Venue Negative
    //if already voted, update the vote
}

- (IBAction)positiveButtonPressed:(UIButton *)sender
{
    //Rate the Venue Positive
    //if already voted, update the vote
}
@end
