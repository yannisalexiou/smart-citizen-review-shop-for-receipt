//
//  VenueTableViewCell.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 30/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "VenueTableViewCell.h"

@implementation VenueTableViewCell

//- (void)awakeFromNib
//{
//    // Initialization code
//    NSLog(@"awakeFromNib");
//    [super awakeFromNib];
//    
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"initWithStyle");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    NSLog(@"setSelected");
    
}

- (IBAction)cellRightButtonPressed:(UIButton *)sender
{
    
}
@end
