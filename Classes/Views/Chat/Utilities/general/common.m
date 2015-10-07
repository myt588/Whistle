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
#import "common.h"
#import "NavigationController.h"
#import "Whistle-Swift.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[InitialView alloc] init]];
    [target presentViewController:navigationController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SaveUserDefault(NSString *key, BOOL value)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([key isEqual: PF_LOCAL_RECENT_LOADED])
    {
        NSUserDefaults *recentLoaded = [NSUserDefaults standardUserDefaults];
        PFUser *user = [PFUser currentUser];
        [recentLoaded setBool: value forKey: [NSString stringWithFormat:@"%@_%@", PF_LOCAL_RECENT_LOADED, user.objectId]];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL GetUserDefault(NSString *key)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([key isEqual:PF_LOCAL_RECENT_LOADED])
    {
        NSUserDefaults *recentLoaded = [NSUserDefaults standardUserDefaults];
        PFUser *user = [PFUser currentUser];
        return [recentLoaded boolForKey:[NSString stringWithFormat:@"%@_%@", PF_LOCAL_RECENT_LOADED, user.objectId]];
    }
    return NO;
}
