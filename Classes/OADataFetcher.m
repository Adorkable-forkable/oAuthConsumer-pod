//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"




@implementation OADataFetcher

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)dealloc {
}


- (void)didFailWithError:(NSError *)error withData:(NSData *)data
{
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:data
															didSucceed:NO];

	if ( delegate )
		[delegate performSelector:didFailSelector withObject:ticket withObject:error];
	else if ( handler )
		handler(ticket, nil, error);
}


- (void)didFinishLoadingWithData:(NSData *)data {
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:data
															didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];

	if ( delegate )
		[delegate performSelector:didFinishSelector withObject:ticket withObject:data];
	else if (handler )
		handler(ticket, data, nil);
}


- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest
					delegate:(id)aDelegate
		   didFinishSelector:(SEL)finishSelector
			 didFailSelector:(SEL)failSelector
{
	request = aRequest;
    delegate = aDelegate;
	handler = nil;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
    [request prepare];
    
    NSURLSession *session = [NSURLSession sharedSession];
    connectionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            [self didFinishLoadingWithData:data];
        } else {
            [self didFailWithError:error withData:data];
        }
    }];
    [connectionTask resume];
}


- (void)performRequest:(OAMutableURLRequest *)aRequest withHandler:(OADataFetcherCompletedHandler)_handler
{
	request = aRequest;
	handler = _handler;
	delegate = nil;
	
	[request prepare];
	
    NSURLSession *session = [NSURLSession sharedSession];
    connectionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            [self didFinishLoadingWithData:data];
        } else {
            [self didFailWithError:error withData:data];
        }
    }];
    [connectionTask resume];
}
@end
