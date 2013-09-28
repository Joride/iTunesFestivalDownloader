 //
//  FileDownloader.m
//  iTunesFestivalDownloader
//
//  Created by Jorrit van Asselt on 28-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import "FileDownloader.h"

@implementation FileDownloader
- (void)main {
    NSURL * URL = [NSURL URLWithString: self.URLString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod: @"GET"];
    NSString * cookieString = self.cookieString;
    [request addValue: cookieString forHTTPHeaderField: @"Cookie"];
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}

//#pragma mark - NSURLConnectionDelegate
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    _expectedContentLength = response.expectedContentLength;
//    if (_expectedContentLength == NSURLResponseUnknownLength){
//    }
//    self.progression = 0.0f;
//    _cumulativeReveivedBytes = 0;
//}
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    _cumulativeReveivedBytes += data.length;
//    CGFloat received = _cumulativeReveivedBytes * 1.0f;
//    CGFloat expected = _expectedContentLength * 1.0f;
//    
//    self.progression = (received / expected);
//    NSLog(@"%.2f of %.2f bytes received. (%2.2f%%)", received, expected, self.progression * 100.0f);
//    
//    if (_data == nil) {
//        _data = [[NSMutableData alloc] init];
//    }
//    [_data appendData: data];
//}
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    switch (self.currentDownloadType) {
//        case kDownloadTypeBandWidthsList:
//            [self handleBandWithList: _data];
//            break;
//        case kDownloadTypeStreamFilesList:
//            [self handleStreamFilesList: _data];
//            break;
//        case kDownloadTypeTSFile:
//            [self handleTSFileData: _data];
//            break;
//            
//        default:
//            break;
//    }
//    _data = nil;
//    _expectedContentLength = 0;
//    _cumulativeReveivedBytes = 0;
//    self.progression = 0.0f;
//}
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    _data = nil;
//    NSLog(@"%@, %@", error, [error localizedDescription]);
//    
//}
@end
