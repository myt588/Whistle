//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "ProgressHUD.h"

#import "utilities.h"

#import "RecentView.h"
#import "RecentCell.h"
#import "ChatView.h"
#import "NavigationController.h"
#import "YALFoldingTabBarController.h"
#import "Whistle-Swift.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentView()
{
    Firebase *firebase;
	NSMutableArray *recents;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Recent";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	recents = [[NSMutableArray alloc] init];
    //-----------------------------------------------------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_APP_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_USER_LOGGED_IN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadRecents];
	}
	else LoginUser(self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((YALFoldingTabBarController *) self.tabBarController).tabBarView.hidden = NO;
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = [PFUser currentUser];
    if ((user != nil) && (firebase == nil))
    {
        firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
        FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:user.objectId];
        [query observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
         {
             [recents removeAllObjects];
             if (snapshot.value != [NSNull null])
             {
                 NSArray *sorted = [[snapshot.value allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                    {
                                        NSDictionary *recent1 = (NSDictionary *)obj1;
                                        NSDictionary *recent2 = (NSDictionary *)obj2;
                                        NSDate *date1 = String2Date(recent1[@"date"]);
                                        NSDate *date2 = String2Date(recent2[@"date"]);
                                        return [date2 compare:date1];
                                    }];
                 for (NSDictionary *recent in sorted)
                 {
                     [recents addObject:recent];
                 }
             }
             [self.tableView reloadData];
             [self updateTabCounter];
         }];
    }
}

#pragma mark - Helper methods
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    int total = 0;
    for (PFObject *recent in recents)
    {
        total += [recent[@"counter"] intValue];
    }
    MIBadgeButton *button = ((YALFoldingTabBarController *) self.tabBarController).tabBarView.myButtons[6];
    button.badgeString = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [UIApplication sharedApplication].applicationIconBadgeNumber = total;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = total;
    [currentInstallation saveInBackground];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [firebase removeAllObservers];
    firebase = nil;
    [recents removeAllObjects];
    [self.tableView reloadData];
    [self updateTabCounter];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
			   otherButtonTitles:@"Single recipient", @"Multiple recipients", @"Address Book", @"Facebook Friends", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [recents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
	[cell bindData:recents[indexPath.row]];
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDictionary *recent = recents[indexPath.row];
    [recents removeObject:recent];
    [self updateTabCounter];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    DeleteRecentItem(recent);
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSDictionary *recent = recents[indexPath.row];
    RestartRecentChat(recent);
    [self actionChat:recent[@"groupId"]];
}

@end
