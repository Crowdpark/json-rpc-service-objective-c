//
//  API.m
//  AnteUpTabs
//
//  Created by Marin Todorov on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "API.h"
#import "FacebookController.h"

#pragma mark - private interface
@interface API(privates)
//privates

@end

#pragma mark - implementation
@implementation API

@synthesize me;

#pragma mark - singleton
static API *sharedInstance;

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ { 

        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kApiHost]];
        [sharedInstance setDefaultHeader:@"Content-Type" value:@"application/json"];
        [sharedInstance setDefaultHeader:@"User-Agent" value:@"AnteUpApp 1.0"];
        [sharedInstance setDefaultHeader:@"Accept-Language" value:@"en"];
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [sharedInstance setDefaultHeader:@"Accept" value:@"application/json"];

        sharedInstance.parameterEncoding = AFJSONParameterEncoding;
        [sharedInstance registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
    });
}

+(API*)sharedInstance
{
    return sharedInstance;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self !=nil) {
        //API is up
        requestId = 0;
        facebookCookie = nil;
        [self buildFacebookCookie];
    }
    return self;
}

-(void)dealloc
{
    facebookCookie = nil;
}

#pragma mark - building the facebook cookie
-(void)buildFacebookCookie
{
    FacebookController* fbController = [FacebookController sharedInstance];
    if ([fbController.facebook isSessionValid]==YES) {
        //set a cookie to the anteup API

        NSString* cookieHeader = [NSString stringWithFormat:@"%@=%@; %@=%@", 
                                  [NSString stringWithFormat:@"fbm_%@",kFacebookAppId],
                                  [NSString stringWithFormat:@"base_domain=%@", kApiCookieBaseDomain],
                                  [NSString stringWithFormat:@"fbat_%@",kFacebookAppId],
                                  [fbController.facebook accessToken]
                                  ];
        
        [self setDefaultHeader:@"Cookie" value: cookieHeader];
    }
}

#pragma mark - API commands
-(void)command:(NSString*)cmd withParams:(NSDictionary*)p complete:(ResultBlock)c error:(ErrorBlock)e
{
    requestId++;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithLong:requestId] forKey:@"id"];
    [params setObject:cmd forKey:@"method"];

    if (p!=nil) {
        [params setObject:[NSArray arrayWithObject:p] forKey:@"params"];
    } else {
        [params setObject:[NSArray array] forKey:@"params"];
    }
    
    
    //make the call 
    [self postPath:kAPIPath 
       parameters:params 
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //success
              
              //NSLog(@"resp: %@", responseObject);
              c(responseObject);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"response: %@", operation.responseString);
              
              //failure
              NSLog(@"error: %@", [error description]);
              NSLog(@"error: %@", [error localizedDescription]);

              e(error);
          }];
}

/*
-(NSURL*)betURLforId:(NSString*)betId
{
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"http://dev.shakeonitapp.com/#!/bet/%@",betId ]
            ];
}
 */

-(void)logout
{
    requestId = 0;
}

@end
