//
//  FileDownloader.m
//  iTunesFestivalDownloader
//
//  Created by Joride on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import "FileDownloader.h"

typedef void(^DownloadCompletionHandler)(BOOL);

@interface FileDownloader ()

// local file handling 
@property (nonatomic) CGFloat progression;
@property (nonatomic, copy) NSString * localSavePath;
@property (nonatomic, copy) NSString * localFileName;

// remote files
@property (nonatomic, copy) NSString * URLString;
@property (nonatomic, copy) NSString * dateString;
@property (nonatomic, copy) NSString * GETParameters;
@property (nonatomic, copy) NSString * initialFileName;
@property (nonatomic, copy) NSString * cookieString;

// completion
@property (nonatomic, strong) DownloadCompletionHandler completionHandler;
@end

@implementation FileDownloader{
    NSMutableData * _data;
    long long                   _expectedContentLength;
    NSInteger                   _cumulativeReveivedBytes;
}

- (id) initWithFileName: (NSString *) fileName
               savePath: (NSString *) savePath
                    URL: (NSString *) URL
                   date: (NSString *) date
             remotePath: (NSString *) remotePath
          GETParameters: (NSString *) GETParameters
                 cookie: (NSString *) cookie{
    
    self = [super init];
    if (self) {
        self.localFileName = fileName;
        self.localSavePath = savePath;
        
        self.URLString = [NSString stringWithFormat: @"%@%@/v1/%@/%@%@", URL, date, remotePath, fileName, GETParameters];
        self.GETParameters = GETParameters;
        self.cookieString = cookie;
    }
    
    return self;
}

- (void) startDownloadWithCompletion: ( void(^)(BOOL success)) completion{
    self.completionHandler = completion;
    NSString * savePath = [self.localSavePath stringByAppendingPathComponent: self.localFileName];
    if ([self fileExistsAtPath: savePath]) {
        [self completeWithSuccess: YES];
        return;
    }
    
    NSURL * URL = [NSURL URLWithString: self.URLString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod: @"GET"];
    NSString * cookieString = self.cookieString;
    [request addValue: cookieString forHTTPHeaderField: @"Cookie"];
    
    NSLog(@"Start download %@", self.localFileName);
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request
                                                                   delegate: self];
}
- (BOOL) fileExistsAtPath: (NSString *) path{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath: path];
}

- (BOOL) saveData: (NSData *) data{
    NSError * error = nil;
    NSString * savePath = [self.localSavePath stringByAppendingPathComponent: self.localFileName];
    return [data writeToFile: savePath
                     options: NSDataWritingAtomic
                       error: &error];
}
- (void) reset{
    _data = nil;
    _expectedContentLength = 0;
    _cumulativeReveivedBytes = 0;
    self.progression = 0.0f;
}
- (void) completeWithSuccess: (BOOL) succes{
    if (self.completionHandler != nil) {
        self.completionHandler(succes);
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _expectedContentLength = response.expectedContentLength;
    if (_expectedContentLength == NSURLResponseUnknownLength){
    }
    self.progression = 0.0f;
    _cumulativeReveivedBytes = 0;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    _cumulativeReveivedBytes += data.length;
    CGFloat received = _cumulativeReveivedBytes * 1.0f;
    CGFloat expected = _expectedContentLength * 1.0f;
    
    self.progression = (received / expected);
    //NSLog(@"%.2f of %.2f bytes received. (%2.2f%%)", received, expected, self.progression * 100.0f);
    
    if (_data == nil) {
        _data = [[NSMutableData alloc] init];
    }
    [_data appendData: data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"End download %@", self.localFileName);
    BOOL succes = [self saveData: _data];
    [self reset];
    [self completeWithSuccess: succes];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@, %@", error, [error localizedDescription]);
    [self reset];
    [self completeWithSuccess: NO];

    
}

@end
