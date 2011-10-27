//
//  DeliveryListViewController.m
//  SWMaestroDelivery
//
//  Created by 전 수열 on 11. 10. 26..
//  Copyright (c) 2011년 Joyfl. All rights reserved.
//

#import "DeliveryListViewController.h"

@interface DeliveryListViewController(Private)
- (void)startBusy;
- (void)stopBusy;
- (NSString *)getHtml:(NSString *)url;
- (NSMutableArray *)parseXML:(NSString *)xml;
- (NSString *)parseXMLTag:(NSString *)xml:(NSString *)tag;
- (NSString *)getSectionHeader:(NSString *)date;

@end


@implementation DeliveryListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	

	dates = [[NSMutableArray alloc] init];
	deliveries = [[NSMutableDictionary alloc] init];
	
//	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//	indicatorView.center = CGPointMake( 125, 50 );
//	[self startBusy];
	
	UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake( 125, 50, 30, 40 )];
	indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[indicatorView startAnimating];
	
	loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[loadingAlert addSubview:indicatorView];
	
	[self startBusy];
	
	NSThread *deliveryLoadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadDeliveries:) object:self];
	[deliveryLoadThread start];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	deliveries = nil;
	loadingAlert = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [dates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	NSLog( @"count" );
    return [[deliveries objectForKey:[dates objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [dates objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSMutableDictionary *delivery = [[deliveries objectForKey:[dates objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
	cell.textLabel.text = [delivery objectForKey:@"to"];
//	cell.detailTextLabel.text = [delivery objectForKey:@"from"];
	
	
	NSLog( @"%@", delivery );
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return dates;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

#

- (void)loadDeliveries:(id)sender
{
//	NSString *xml = [self getHtml:@"http://joyfl.kr/xoul/services/soma_delivery/delivery.php?begin=0&end=10"];
	NSString *xml = @"<delivery><date>2011-02-23 21:00:00</date><from>from0</from><to>to0</to></delivery><delivery><date>2011-02-22 21:00:00</date><from>from1</from><to>to1</to></delivery><delivery><date>2011-02-20 21:00:00</date><from>from2</from><to>to2</to></delivery>";
	[self parseXML:xml];
	[self.tableView reloadData];
	[self stopBusy];
}

- (NSString *)getHtml:(NSString *)url
{
	NSURLResponse *response;
	NSError *error;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSMutableArray *)parseXML:(NSString *)xml
{
//	xml = [[xml componentsSeparatedByString:@"?>"] objectAtIndex:1];
	NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[xml componentsSeparatedByString:@"<delivery>"]];
	
	// <delivery></delivery> 태그 분리
	for( int i = 0; i < arr.count; i++ )
		[arr replaceObjectAtIndex:i withObject:[[[arr objectAtIndex:i] componentsSeparatedByString:@"</delivery>"] objectAtIndex:0]];
	
	for( int i = 1; i < arr.count; i++ )
	{
		NSString *tag = [arr objectAtIndex:i];
		NSString *date = [self parseXMLTag:tag:@"date"];
		NSString *from = [self parseXMLTag:tag:@"from"];
		NSString *to = [self parseXMLTag:tag:@"to"];
		
		NSMutableDictionary *delivery = [[NSMutableDictionary alloc] init];
		[delivery setValue:date forKey:@"date"];
		[delivery setValue:from forKey:@"from"];
		[delivery setValue:to forKey:@"to"];
		
//		[deliveries addObject:delivery];
		NSString *sectionHeader = [self getSectionHeader:date];
		if( [dates containsObject:sectionHeader] == NO )
		{
			[dates addObject:sectionHeader];
			[deliveries setObject:[[NSMutableArray alloc] init] forKey:sectionHeader];
		}
		[[deliveries objectForKey:sectionHeader] addObject:delivery];
	}
	
	return arr;
}

- (NSString *)parseXMLTag:(NSString *)xml:(NSString *)tag
{
	NSString *startTag = [NSString stringWithFormat:@"<%@>", tag];
	NSString *endTag = [NSString stringWithFormat:@"</%@>", tag];
	return [[[[xml componentsSeparatedByString:startTag] objectAtIndex:1] componentsSeparatedByString:endTag] objectAtIndex:0];
}

- (NSString *)getSectionHeader:(NSString *)date
{
	return [[date componentsSeparatedByString:@" "] objectAtIndex:0];
}

- (void)startBusy
{
	[loadingAlert show];
}

- (void)stopBusy
{
	[loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
