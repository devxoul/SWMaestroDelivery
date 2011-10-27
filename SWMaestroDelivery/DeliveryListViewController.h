//
//  DeliveryListViewController.h
//  SWMaestroDelivery
//
//  Created by 전 수열 on 11. 10. 26..
//  Copyright (c) 2011년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeliveryListViewController : UITableViewController
{
	NSMutableArray *dates;
	NSMutableDictionary *deliveries;
	UIAlertView *loadingAlert;
}

@end
