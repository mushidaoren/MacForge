//
//  MF_accountManager.m
//  MacForge
//
//  Created by Wolfgang Baird on 12/25/19.
//  Copyright © 2019 MacEnhance. All rights reserved.
//

#import "MF_accountManager.h"

@implementation MF_accountManager

/*
 * @returns YES upon success
 *          NO  upon failure
 * @param error is set upon failure
 */

- (void)createAccountWithUsername:(NSString *)username
                            email:(NSString *)email
                         password:(NSString *)password
                      andPhotoURL:(NSURL *)photoURL
            withCompletionHandler:(void (^)(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable err))handler {
    
    NSLog(@"Creating account:");
    NSLog(@"\n%@\n%@\n%@\n%@", username, email, password, photoURL.absoluteString);
    
    /*
     * XXX
     * Before I createUser():
     * 1. verify email
     * 2. verify password
     * 3. verify if user already exists or we want to make a change through the register view that works as an "edit" form...
     */
    
    /* Create new user */
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        /* oops, something failed; call handler and return */
        if (error) {
            handler(authResult, error);
            return;
        }
        
        /*
         * We need to set the username and the photo for this user.
         * Pretty interesting that the API doesn't support this through `-createUser:`;
         * Using the change-request API should do it!
         */
        if (password.length && photoURL.absoluteString.length) {
            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
            
            changeRequest.photoURL = photoURL;
            changeRequest.displayName = username;
            
            [changeRequest commitChangesWithCompletion:^(NSError *_Nullable _error) {
                /* call handler */
                handler(authResult, _error);
            }];
        }
    }];
}

- (void)updateAccountWithUsername:(NSString *)username
                      andPhotoURL:(NSURL *)photoURL
            withCompletionHandler:(void (^)(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable err))handler {
    NSLog(@"Updating account:");
    
    // Fix local file paths
    if ([photoURL.absoluteString.pathComponents.firstObject isEqualToString:@"/"]) {
        NSString *fix = photoURL.absoluteString;
        if ([NSFileManager.defaultManager fileExistsAtPath:fix]) {
            fix = [@"file://" stringByAppendingString:fix];
            photoURL = [NSURL URLWithString:fix];
        }
    }
    
    NSLog(@"\n%@\n%@", username, photoURL.absoluteString);
    
    FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
    
    changeRequest.photoURL = photoURL;
    changeRequest.displayName = username;
    
    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable _error) {
        handler(nil, _error);
    }];
}

- (void)loginAccountWithEmail:(NSString *)email
                  andPassword:(NSString *)password
        withCompletionHandler:(void (^)(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable err))handler {
    
    NSLog(@"Loging-in account:");
    NSLog(@"\n%@\n%@", email, password);
    
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        handler(authResult, error);
    }];
}

//- (void)createAccountWithUsername:(NSString *)username
//                            email:(NSString *)email
//                         password:(NSString *)password
//                      andPhotoURL:(NSURL *)photoURL
//            withCompletionHandler:(void (^)(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable err))handler {
//
//    NSLog(@"Creating account:");
//    NSLog(@"\n%@\n%@\n%@\n%@", username, email, password, photoURL.absoluteString);
//
//    /*
//     * XXX
//     * Before I createUser():
//     * 1. verify email
//     * 2. verify password
//     * 3. verify if user already exists or we want to make a change through the register view that works as an "edit" form...
//     */
//
//    /* Create new user */
//    [[FIRAuth auth] createUserWithEmail:email
//                               password:password
//                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
//                                 /* oops, something failed; call handler and return */
//                                 if (error) {
//                                     handler(authResult, error);
//                                     return;
//                                 }
//
//                                 /*
//                                  * We need to set the username and the photo for this user.
//                                  * Pretty interesting that the API doesn't support this through `-createUser:`;
//                                  * Using the change-request API should do it!
//                                  */
//                                 FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
//
//                                 changeRequest.photoURL = photoURL;
//                                 changeRequest.displayName = username;
//
//                                 [changeRequest commitChangesWithCompletion:^(NSError *_Nullable _error) {
//                                     // (npyl): talk to wolf about setting authResult to (-1) as an internal way of understanding that the problem happened during the change phase; there is no other way of knowing this unless we analyse the error nicely.
//
//                                     /* call handler */
//                                     handler(nil, _error);
//                                 }];
//                             }];
//}
//
//- (void)loginAccountWithEmail:(NSString *)email
//                  andPassword:(NSString *)password
//        withCompletionHandler:(void (^)(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable err))handler {
//
//    NSLog(@"Loging-in account:");
//    NSLog(@"\n%@\n%@", email, password);
//
//    [[FIRAuth auth] signInWithEmail:email
//                           password:password
//                         completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
//                             handler(authResult, error);
//                         }];
//}

/*

- (IBAction)fireBaseFireStoreTest:(id)sender {
    NSLog(@"Hello");
        
//    NSDictionary *docData = @{
//      @"purchases": @{
//        @"520974": @YES,
//      }
//    };
    
    // Write to the document reference, merging data with existing
    // if the document already exists
//    [[[self.db collectionWithPath:@"users"] documentWithPath:FIRAuth.auth.currentUser.uid]
//        setData:docData
//        merge:YES
//        completion:^(NSError * _Nullable error) {
//          // ...
//    }];

//    FIRDocumentReference *docRef = [[self.db collectionWithPath:@"users"] documentWithPath:FIRAuth.auth.currentUser.uid];
//    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
//        if (snapshot.exists) {
//            // Document data may be nil if the document exists but has no keys or values.
////            NSLog(@"Document data: %@", snapshot.data);
//            NSLog(@"Document data: %@", snapshot.data[@"purchases"]);
//            self->_reviewsDict = snapshot;
//        } else {
//            NSLog(@"Document does not exist");
//        }
//    }];
    
//    FIRDocumentReference *docRef = [[self.db collectionWithPath:@"reviews"] documentWithPath:@"520974"];
//    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
//        if (snapshot.exists) {
//            // Document data may be nil if the document exists but has no keys or values.
////            NSLog(@"Document data: %@", snapshot.data);
//            NSLog(@"Document data: %@", snapshot.data[@"ratings"]);
//            testing = snapshot.data;
//        } else {
//            NSLog(@"Document does not exist");
//        }
//    }];
}

- (IBAction)fireBaseLogout:(id)sender {
    NSError *err;
    [FIRAuth.auth signOut:&err];
    
    _imgAccount.image = [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].image;
    _viewAccount.title = [NSString stringWithFormat:@"                    %@", [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].fullName];
    
    _loginImageURL.stringValue = @"";
    _loginUsername.stringValue = @"";
    _loginUID.stringValue = @"";
    _loginEmail.stringValue = @"";
    _loginPassword.stringValue = @"";
    
    NSLog(@"%@", err);
}

- (IBAction)fireBaseRegister:(id)sender {
    FIRUser *user = [FIRAuth auth].currentUser;
    
    if (user) {
        FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
        changeRequest.photoURL = [NSURL URLWithString:_loginImageURL.stringValue];
        changeRequest.displayName = _loginUsername.stringValue;
        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
            NSLog(@"%@", error);
            [self fireBaseSetup];
        }];
    } else {
        [[FIRAuth auth] signInWithEmail:_loginEmail.stringValue
                               password:_loginPassword.stringValue
                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                            NSLog(@"%@", error);
                                            [self fireBaseSetup];
                                        }];
    }
}

- (IBAction)fireBaseLogin:(id)sender {
    FIRUser *user = [FIRAuth auth].currentUser;
    
//    FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
//    changeRequest.photoURL = [NSURL URLWithString:@"https://avatars3.githubusercontent.com/u/1920148?s=460&v=4"];
//    changeRequest.displayName = _loginUsername.stringValue;
//    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
//        NSLog(@"%@", error);
//        // ...
//    }];
    
    // [END get_user_profile]
    // [START user_profile]
    if (user) {
        // The user's ID, unique to the Firebase project.
        // Do NOT use this value to authenticate with your backend server,
        // if you have one. Use getTokenWithCompletion:completion: instead.
        NSString *uid = user.uid;
        NSString *email = user.email;
        NSURL *photoURL = user.photoURL;
        NSString *displayName = user.displayName;
        // [START_EXCLUDE]
        _loginUID.stringValue = uid;
        _loginEmail.stringValue = email;
        if (displayName)
            _viewAccount.title = [NSString stringWithFormat:@"                    %@", displayName];
        else
            _viewAccount.title = [NSString stringWithFormat:@"                    %@", [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].fullName];
        
        static NSURL *lastPhotoURL = nil;
        lastPhotoURL = photoURL;  // to prevent earlier image overwrites later one.
        if (photoURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
                NSImage *image = [NSImage sd_imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    if (photoURL == lastPhotoURL) {
                        self->_imgAccount.image = image;
                    }
                });
            });
        } else {
            _imgAccount.image = [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].image;
        }
        // [END_EXCLUDE]
    } else {
        [[FIRAuth auth] signInWithEmail:_loginEmail.stringValue
                               password:_loginPassword.stringValue
                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                            NSLog(@"%@", error);
                                            [self fireBaseSetup];
                                        }];
    }
}

- (void)fireBaseSetup {
//    self.ref = [[FIRDatabase database] reference];
//    self.db = [FIRFirestore firestore];
    
    FIRUser *user = [FIRAuth auth].currentUser;
        
    // [END get_user_profile]
    // [START user_profile]
    if (user) {
        // The user's ID, unique to the Firebase project.
        // Do NOT use this value to authenticate with your backend server,
        // if you have one. Use getTokenWithCompletion:completion: instead.
        NSString *uid = user.uid;
        NSString *email = user.email;
        NSURL *photoURL = user.photoURL;
        NSString *displayName = user.displayName;
        
        _loginUID.stringValue = uid;
        _loginEmail.stringValue = email;
        if (displayName) {
            _loginUsername.stringValue = displayName;
            _viewAccount.title = [NSString stringWithFormat:@"                    %@", displayName];
        } else {
            _viewAccount.title = [NSString stringWithFormat:@"                    %@", [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].fullName];
        }
        
        _loginImageURL.stringValue = photoURL.absoluteString;
        
        static NSURL *lastPhotoURL = nil;
        lastPhotoURL = photoURL;  // to prevent earlier image overwrites later one.
        if (photoURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
                NSImage *image = [NSImage sd_imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    if (photoURL == lastPhotoURL) {
                        self->_imgAccount.image = image;
                    }
                });
            });
        } else {
            _imgAccount.image = [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].image;
            _viewAccount.title = [NSString stringWithFormat:@"                    %@", [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]].fullName];
        }
    }
}
 
 */

@end


