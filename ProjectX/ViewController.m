//
//  ViewController.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *venuesTableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)rightBarButtonItemPressed:(UIBarButtonItem *)sender;

@end

@implementation ViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectedVenueSegue"])
    {
        SelectedVenueVC *nextViewController = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        //Push the -> objectAtIndex:indexPath.row <- to the new VC
        //You must push an object from this VC to the nextViewController
    }
}

#pragma mark - UITableViewDataSource
- (void)refreshTable
{
    //TODO: refresh your data
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5; //Change this Value
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    //[tableView registerClass:[VenueTableViewCell class] forCellReuseIdentifier:@"cell"];
    VenueTableViewCell *cell = (VenueTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.cellImageView.image = [UIImage imageNamed:@"defaultImage"];
    [cell.cellTitleLabel setText:[NSString stringWithFormat:@"Row %i in Section %i", [indexPath row], [indexPath section]]];
    cell.cellSubtitleLabel.text = @"swag";
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //[self performSegueWithIdentifier:@"selectedVenueSegue" sender:indexPath];
    //    UIViewControllerGASelectedReport *pushVC = [[UIViewControllerGASelectedReport alloc] initWithNibName:@"selectedReportVC" bundle:nil];
    //    [self.navigationController pushViewController:pushVC animated:YES];
    
}

- (IBAction)rightBarButtonItemPressed:(UIBarButtonItem *)sender
{
    //[self performSegueWithIdentifier:@"FullMapVenuesSegue" sender:self];
    
    //UIViewController *fullMapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VenuesFullMapVCID"];
    //fullMapVC.modalTransitionStyle = UIModalPresentationOverFullScreen;
    //[self presentViewController:fullMapVC animated:YES completion:nil];
}
@end
