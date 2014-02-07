//
//  FindCityViewController.h
//  NTApiSample
//
//  Created by Ethan Nagel on 2/3/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FindCityViewControllerDelegate;


@interface FindCityViewController : UITableViewController

@property (nonatomic,weak) id<FindCityViewControllerDelegate> delegate;

-(id)init;

@end


@protocol FindCityViewControllerDelegate <NSObject>

@optional
-(void)findCityViewController:(FindCityViewController *)viewController selectedCityWithCurrentWeather:(CurrentWeather *)currentWeather;

@end
