//
//  MainViewController.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/1/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "MainViewController.h"

#import "FindCityViewController.h"


@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FindCityViewControllerDelegate>
{
    NTApiRequest *_currentRequest;
}

@property (nonatomic) NSArray *currentWeatherItems;

@end


@implementation MainViewController


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
    
    self.title = @"Updating...";

    _currentRequest = [[OpenWeatherApiClient apiClient] beginGetCurrentWeatherWithCityCodes:AppSettings.defaultSettings.cityCodes responseHandler:^(NSArray *currentWeatherItems, NTApiError *error)
     {
         _currentRequest = nil;
         
         self.title = @"Current Weather";
         
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
    
    // Grab the current weather if we haven't...
    
    if ( !self.currentWeatherItems )
    {
        [self beginRefreshWeather];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    [super viewWillDisappear:animated];
}


#pragma mark - IBActions


-(IBAction)addCity:(id)sender
{
    FindCityViewController *viewController = [[FindCityViewController alloc] init];
    
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - FindCityViewControllerDelegate


-(void)findCityViewController:(FindCityViewController *)viewController selectedCityWithCurrentWeather:(CurrentWeather *)currentWeather
{
    // Save to our persistent cityCodes list...
    
    NSArray *cityCodes = [AppSettings.defaultSettings.cityCodes arrayByAddingObject:currentWeather.cityCode];
    
    AppSettings.defaultSettings.cityCodes = cityCodes;
    
    // And add it to our current weather array...
    
    self.currentWeatherItems = [self.currentWeatherItems arrayByAddingObject:currentWeather];

    [self.tableView reloadData];
    
    [viewController.navigationController popViewControllerAnimated:YES];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CurrentWeather *item = self.currentWeatherItems[indexPath.row];
    
    cell.textLabel.text = item.cityName;
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@, %.0f degrees", item.weatherDescription, item.temp];
    
    return cell;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        CurrentWeather *currentWeather = self.currentWeatherItems[indexPath.row];
        
        [tableView beginUpdates];
        
        // update the data models...

        NSMutableArray *currentWeatherItems = [self.currentWeatherItems mutableCopy];
        
        [currentWeatherItems removeObjectAtIndex:indexPath.row];
        
        self.currentWeatherItems = currentWeatherItems;
        
        NSMutableArray *cityCodes = [AppSettings.defaultSettings.cityCodes mutableCopy];
        
        [cityCodes removeObject:currentWeather.cityCode];
        
        AppSettings.defaultSettings.cityCodes = [cityCodes copy];
        
        // remove from the tableView...
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Commit...
        
        [tableView endUpdates];
    }
}



@end
