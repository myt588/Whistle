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

#import "AppConstant.h"
#import "PFUser+Util.h"

#import "push.h"
#import "Whistle-Swift.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserAssign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
    installation[@"whistle"] = @YES;
    installation[@"chat"] = @YES;
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) NSLog(@"ParsePushUserAssign save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserResign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	[installation removeObjectForKey:PF_INSTALLATION_USER];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) NSLog(@"ParsePushUserResign save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification1(NSString *groupId, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			NSArray *recents = [snapshot.value allValues];
			NSDictionary *recent = [recents firstObject];
			if (recent != nil)
			{
				SendPushNotification2(recent[@"members"], text, PF_INSTALLATION_CHAT);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification2(NSArray *members, NSString *text, NSString *type)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *message = [NSString stringWithFormat:@"%@: %@", [PFUser currentName], text];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID containedIn:members];
    [query whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentId]];
    [query setLimit:1000];
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
    if ([type isEqual: PF_INSTALLATION_CHAT])    [queryInstallation whereKey:PF_INSTALLATION_CHAT equalTo: @YES];
    if ([type isEqual: PF_INSTALLATION_WHISTLE]) [queryInstallation whereKey:PF_INSTALLATION_WHISTLE equalTo: @YES];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:@{@"alert":message, @"sound":@"default", @"badge":@"Increment", @"type":type}];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"SendPushNotification2 send error.");
         }
     }];
}
