//
//  MainViewController.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/1/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "MainViewController.h"


#define DEFAULT_CITY_CODES @"5391959,5128581,2643743,1816670,2147714,5309842"        // SF,New York,London,Beijing,Sydney,Yarnell


@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_cityCodes;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *cityCodes;
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


#pragma mark - cityCode persistence


-(NSArray *)cityCodes
{
    if ( !_cityCodes )
    {
        NSString *csv = [NSUserDefaults.standardUserDefaults valueForKey:@"cityCodes"];
        
        if ( !csv )
        {
            csv = DEFAULT_CITY_CODES;
        }
        
        _cityCodes = [csv componentsSeparatedByString:@","];
    }
    
    return _cityCodes;
}


-(void)setCityCodes:(NSArray *)cityCodes
{
    if ( _cityCodes == cityCodes || [_cityCodes isEqualToArray:cityCodes] )
        return ;
    
    NSString *csv = [cityCodes componentsJoinedByString:@","];
    
    [NSUserDefaults.standardUserDefaults setValue:csv forKey:@"cityCodes"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    _cityCodes = cityCodes;
}


#pragma mark - Data Access


-(void)beginRefreshWeather
{
    [[OpenWeatherApiClient apiClient] beginGetCurrentWeatherWithCityCodes:self.cityCodes responseHandler:^(NSArray *currentWeatherItems, NTApiError *error)
     {
         if ( error )
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error getting weather"
                                                                 message:error.errorMessage
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             
             [alertView show];
             
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Grab the current weather...
    
    [self beginRefreshWeather];
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
