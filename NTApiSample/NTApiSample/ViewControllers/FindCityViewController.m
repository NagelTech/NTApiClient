//
//  FindCityViewController.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/3/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "FindCityViewController.h"


@interface FindCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NTApiRequest *_currentRequest;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) NSArray *currentWeatherItems;

@end


@implementation FindCityViewController


-(id)init
{
    if ( (self=[super initWithNibName:NSStringFromClass(self.class) bundle:nil]) )
    {
    }
    
    return self;
}


#pragma mark - Data Access


-(void)beginSearchWithCityName:(NSString *)cityName
{
    if ( _currentRequest )
    {
        [_currentRequest cancel];
    }
    
    self.title = @"Searching...";
    
    _currentRequest = [[OpenWeatherApiClient apiClient] beginFindCitiesWithName:cityName
                                                                     searchType:OpenWeatherSearchTypeLike
                                                                       maxItems:20
                                                                responseHandler:^(NSArray *currentWeatherItems, NTApiError *error)
    {
        self.title = @"Add City";
        
        _currentRequest = nil;
        
        if ( error.errorCode == NTApiErrorCodeRequestCancelled  )
            return ;    // ignore cancelled requests.

        if ( error ) // display API errors
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


#pragma mark - UIViewControler overrides


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add City";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISearchBarDelegate


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Only search when the user asks...
    
    // Note: searching with no text will generate an error from the server,
    // we leave that so you can see how error capturing & reporting works ;)

    [self beginSearchWithCityName:self.searchBar.text];
}


#pragma mark - UITableViewDataSource/Delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentWeatherItems.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"Default";
    
    CurrentWeather *currentWeather = self.currentWeatherItems[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if ( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = currentWeather.cityName;
    cell.detailTextLabel.text = currentWeather.country;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrentWeather *currentWeather = self.currentWeatherItems[indexPath.row];

    if ( [self.delegate respondsToSelector:@selector(findCityViewController:selectedCityWithCurrentWeather:)] )
    {
        [self.delegate findCityViewController:self selectedCityWithCurrentWeather:currentWeather];
    }
    
    else
        [self.navigationController popViewControllerAnimated:YES];  // default functionality
}


@end
