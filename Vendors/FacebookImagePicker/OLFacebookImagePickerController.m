//
//  FacebookImagePickerController.m
//  FacebookImagePicker
//
//  Created by Deon Botha on 16/12/2013.
//  Copyright (c) 2013 Deon Botha. All rights reserved.
//

#import "OLFacebookImagePickerController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface OLFacebookImagePickerController () <OLAlbumViewControllerDelegate>
@property (assign, nonatomic) BOOL haveSeenViewDidAppear;
@end

@implementation OLFacebookImagePickerController

@dynamic delegate;

- (id)init {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    if (self = [super initWithRootViewController:vc]) {
        if ([FBSDKAccessToken currentAccessToken]){
            [self showAlbumList];
        }
    }
    
    return self;
}

- (void)cancelButtonClicked{
    [self.delegate facebookImagePicker:self didFinishPickingImages:@[]];
}

- (void)viewDidAppear:(BOOL)animated{
    if (![FBSDKAccessToken currentAccessToken] && !self.haveSeenViewDidAppear){
        self.haveSeenViewDidAppear = YES;
        
        //Workaround so that we dont include FBSDKLoginKit
        NSArray *permissions = @[@"public_profile", @"user_photos"];
        Class FBSDKLoginManagerClass = NSClassFromString (@"FBSDKLoginManager");
        id login = [[FBSDKLoginManagerClass alloc] init];
        
        SEL aSelector = NSSelectorFromString(@"logInWithReadPermissions:fromViewController:handler:");
        
        if([login respondsToSelector:aSelector]) {
            void (*imp)(id, SEL, id, id, id) = (void(*)(id,SEL,id,id, id))[login methodForSelector:aSelector];
            if( imp ) imp(login, aSelector, permissions, self, ^(id result, NSError *error) {
                if (error) {
                    [self.delegate facebookImagePicker:self didFailWithError:error];
                } else if ([result isCancelled]) {
                    [self.delegate facebookImagePicker:self didFinishPickingImages:@[]];
                } else {
                    [self showAlbumList];
                }
            });
        }
    }
}

- (void)showAlbumList{
    OLAlbumViewController *albumController = [[OLAlbumViewController alloc] init];
    self.albumVC = albumController;
    self.albumVC.delegate = self;
    self.viewControllers = @[albumController];
}

- (void)setSelected:(NSArray *)selected {
    self.albumVC.selected = selected;
}

- (NSArray *)selected {
    return self.albumVC.selected;
}

#pragma mark - OLAlbumViewControllerDelegate methods

- (void)albumViewControllerDoneClicked:(OLAlbumViewController *)albumController {
    [self.delegate facebookImagePicker:self didFinishPickingImages:albumController.selected];
}

- (void)albumViewController:(OLAlbumViewController *)albumController didFailWithError:(NSError *)error {
    [self.delegate facebookImagePicker:self didFailWithError:error];
}

- (void)albumViewController:(OLAlbumViewController *)albumController didSelectImage:(OLFacebookImage *)image{
    if ([self.delegate respondsToSelector:@selector(facebookImagePicker:didSelectImage:)]){
        [self.delegate facebookImagePicker:self didSelectImage:image];
    }
}

- (BOOL)albumViewController:(OLAlbumViewController *)albumController shouldSelectImage:(OLFacebookImage *)image{
    if ([self.delegate respondsToSelector:@selector(facebookImagePicker:shouldSelectImage:)]){
        return [self.delegate facebookImagePicker:self shouldSelectImage:image];
    }
    else{
        return YES;
    }
}

@end
