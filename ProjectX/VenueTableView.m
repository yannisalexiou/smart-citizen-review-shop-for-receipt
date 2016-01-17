//
//  ViewController.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "VenueTableView.h"

@interface VenueTableView ()
@property (strong, nonatomic) IBOutlet UITableView *venuesTableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *venues;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation VenueTableView
{
    NSString *textViewLocation;
    BOOL reachableConnection;
    NSString *administrativeAreaLock;
    NSString *thoroughfare;
    NSUInteger venuesPhotoCounter;

    LocationManager *locationManager;
    Foursquare_Rest *foursq;
    
    Venue *currentVenue;
    NSMutableDictionary *mydictionary;
    NSOperationQueue *operationQueue;
    startTor *tor;
}

@synthesize venues;

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Δημιουργούμε το RefreshControl
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    // Ξεκινάμε την ενημέρωση του table
    [self refreshTable];
    
    tor = [startTor sharedManager];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectedVenueSegue"])
    {
        SelectedVenueVC *nextViewController = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        currentVenue = venues[indexPath.row];
        nextViewController.retrievedVenue = currentVenue;
    }
    else if ([[segue identifier] isEqualToString:@"mapViewSegue"]) {
        VenuesFullMapVC *venuesMapController = segue.destinationViewController;
        venuesMapController.Venues = venues;
    }
}

// Ξεκινάμε τους Observers για να "ακούνε" στα notifications
-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotLocation:)
                                                 name:kGPSResolvedNotif
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotVenues:)
                                                 name:kVenuesResolvedNotif
                                               object:nil];
    
}

- (void)refreshTable
{
    
    // Ξεκινάμε τους Observers
    [self addObservers];
    
    // Παίρνουμε την τοποθεσία
    locationManager = [[LocationManager alloc] init];
    
    
}

#pragma mark - Διαχείριση Διαδικασιών

- (void) gotLocation :(NSNotification*) notif {
    
    // Αφού πήραμε την τοποθεσία σταματάμε την ενημέρωση
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGPSResolvedNotif
                                                  object:nil];
    
    NSDictionary *coordinates = notif.userInfo;
    NSNumber *latitude = [coordinates objectForKey:@"Lat"];
    NSNumber *longtitude = [coordinates objectForKey:@"Lng"];

    
    NSLog(@"got Location");
    
    
    // Κάνουμε κλήση στο Foursquare με την τοποθεσία
    foursq = [[Foursquare_Rest alloc] initWithLat:latitude Long:longtitude];
    [foursq start];
}


- (void) gotVenues :(NSNotification*) notif{
    NSLog(@"got Venues");

    // Αφού πήραμε τα Venues σταματάμε την ενημέρωση
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVenuesResolvedNotif
                                                  object:nil];
    
    NSDictionary *venuesDictionary = notif.userInfo;

    self.venues = [venuesDictionary objectForKey:@"Venues"];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 5; //Change this Value
    return venues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueTableViewCell *cell = (VenueTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    currentVenue = venues[indexPath.row];
    
    cell.cellTitleLabel.text = currentVenue.name;
    cell.cellSubtitleLabel.text = [NSString stringWithFormat:@"%.0fm", currentVenue.location.distance.floatValue];
    
    // Τοποθετούμε εξ'ορισμού την Placeholder εικόνα
    cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];

    // Άμα δεν έχει κατέβει ήδη (cached) η φωτογραφία, ξεκινάμε την διαδικασία
    if (!currentVenue.image)
    {
        // Ξεκινάμε να κατεβάζουμε όταν σταματήσει το drag
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:currentVenue forIndexPath:indexPath];
        }
        
        // if a download is deferred or in progress, return a placeholder image
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    else
    {
        // Άμα έχει γίνει ήδη cached στη μνήμη τότε την βάζουμε απευθείας
        cell.imageView.image = currentVenue.image;
    }

    return cell;
}



#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(Venue *)venue forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.venue = venue;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = venue.image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.venues.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Venue *venue = (self.venues)[indexPath.row];
            
            if (!venue.image)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:venue forIndexPath:indexPath];
            }
        }
    }
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
    
    [self performSegueWithIdentifier:@"selectedVenueSegue" sender:indexPath];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    //    UIViewControllerGASelectedReport *pushVC = [[UIViewControllerGASelectedReport alloc] initWithNibName:@"selectedReportVC" bundle:nil];
    //    [self.navigationController pushViewController:pushVC animated:YES];
    
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end