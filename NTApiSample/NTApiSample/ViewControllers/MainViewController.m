//
//  MainViewController.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/1/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NTApiRequest *_currentRequest;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *cityCodes;
@property (nonatomic) NSArray *currentWeatherItems;

@end


@implementation MainViewController


#pragma mark - Properties


-(NSArray *)cityCodes
{
    return AppSettings.defaultSettings.cityCodes;
}


-(void)setCityCodes:(NSArray *)cityCodes
{
    AppSettings.defaultSettings.cityCodes = cityCodes;
}


#pragma mark - Initialization


-(id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    if ( self )
    {
    }
    
    return self;
}


#pragma mark - Data Access


-(void)beginRefreshWeather
{
    // This is an example of a cancellable request. If a second call is made before the first is completed, it is
    // cancelled...
    
    if ( _currentRequest )
    {
        NSLog(@"Cancelling getCurrentWeather request");
        [_currentRequest cancel];
    }

    _currentRequest = [[OpenWeatherApiClient apiClient] beginGetCurrentWeatherWithCityCodes:self.cityCodes responseHandler:^(NSArray *currentWeatherItems, NTApiError *error)
     {
         _currentRequest = nil;
         
         if ( error )
         {
             if ( error.errorCode != NTApiErrorCodeRequestCancelled ) // don't show error message on cancel
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error getting weather"
                                                                     message:error.errorMessage
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
                 
                 [alertView show];
             }
             
             return ;
         }
         
         self.currentWeatherItems = currentWeatherItems;
         
         [self.tableView reloadData];
     }];
}


#pragma mark - UIViewController overrides


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Current Weather";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(beginRefreshWeather)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCity:)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add a notification so we can refresh when we come back into the foreground...
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(beginRefreshWeather) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Grab the current weather...
    
    [self beginRefreshWeather];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    [super viewWillDisappear:animated];
}


#pragma mark - IBActions


-(IBAction)addCity:(id)sender
{
    // todo
}


#pragma mark - UITableViewDataSource/Delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentWeatherItems.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"Default";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if ( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    CurrentWeather *item = self.currentWeatherItems[indexPath.row];
    
    cell.textLabel.text = item.cityName;
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@, %.0f degrees", item.weatherDescription, item.temp];
    
    return cell;
}



@end
