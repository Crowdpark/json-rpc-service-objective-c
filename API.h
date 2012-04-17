//
//  API.h
//  AnteUpTabs
//
//  Created by Marin Todorov on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 The class expects to find the following defines (or static vars)
 
 #define kApiHost @"www.goanteup.com"
 #define kAPIPort 4242
 #define kAPIPath @"api/v1/app_mobile/"
 */

@interface API : AFHTTPClient
{
    long requestId;
    NSString* facebookCookie;
}

@property (strong, nonatomic) NSDictionary* me;

+(API*)sharedInstance;

-(void)command:(NSString*)cmd withParams:(NSDictionary*)p complete:(ResultBlock)c error:(ErrorBlock)e;

-(void)buildFacebookCookie;
-(void)logout;

@end
