//
//  VenueTableViewCell.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 30/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cellImageView;
@property (strong, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *cellSubtitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cellRightButtonOutlet;

- (IBAction)cellRightButtonPressed:(UIButton *)sender;

@end
