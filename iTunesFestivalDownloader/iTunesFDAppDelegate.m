//
//  iTunesFDAppDelegate.m
//  iTunesFestivalDownloader
//
//  Created by Joride on 26-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import "iTunesFDAppDelegate.h"

typedef enum DownloadTypes{
    kDownloadTypeBandWidthsList,
    kDownloadTypeStreamFilesList,
    kDownloadTypeTSFile
}DownloadType;


@interface iTunesFDAppDelegate () <NSURLConnectionDelegate>
@property (nonatomic, copy) NSString * currentTSFileName;
@property (nonatomic) DownloadType currentDownloadType;
@property (nonatomic) CGFloat progression;
@property (nonatomic, readonly) NSString * currentPath;
@property (nonatomic, strong) NSString * currentFileName;
@property (nonatomic, readonly) NSString * URLString;
@property (nonatomic, strong) NSString * tsFilePath;
@property (nonatomic, strong) NSArray * fileNames;
@end

#define kBaseStorePath @"/Users/jvanasselt/Documents/iTunes Festival/Valerie June/"
#define kBaseURL @"http://streaming.itunesfestival.com/auth/eu6/vod/20130910/v1/"

#define kGETParamaters @"?token=expires=1380482104~access=/auth/*~md5=ef0a6c04a2941c153dfd09a35c84bd9a"
#define kCOOKIEString @"token=expires=1380482104~access=/auth/*~md5=ef0a6c04a2941c153dfd09a35c84bd9a; ITMFID=6625D6BDE013E98DC0DCB739824A7E73; __utma=29778407.422461867.1378066900.1378236135.1378932215.4; __utmz=29778407.1378932215.4.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.422461867.1378066900"
#define kInitialFileName @"313040471_valeriejune_desktop_vod.m3u8"

@implementation iTunesFDAppDelegate{
    NSMutableData * _data;
    long long                   _expectedContentLength;
    NSInteger                   _cumulativeReveivedBytes;
    
    NSInteger _currentIndex;
}

@synthesize currentTSFileName = _currentTSFileName;
@synthesize currentDownloadType = _currentDownloadType;
@synthesize currentPath = _currentPath;
@synthesize currentFileName = _currentFileName;
@synthesize tsFilePath = _tsFilePath;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.currentFileName = kInitialFileName;
    [self downloadBandWidthList];
}
- (void) downloadBandWidthList{
    NSURL * URL = [NSURL URLWithString: self.URLString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod: @"GET"];
    NSString * cookieString = kCOOKIEString;
    [request addValue: cookieString forHTTPHeaderField: @"Cookie"];
    
    self.currentDownloadType = kDownloadTypeBandWidthsList;
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}
- (void) downloadTSFilesList{
    self.currentDownloadType = kDownloadTypeStreamFilesList;
    NSURL * URL = [NSURL URLWithString: self.URLString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod: @"GET"];
    NSString * cookieString = kCOOKIEString;
    [request addValue: cookieString forHTTPHeaderField: @"Cookie"];

    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}
- (void) downloadTSFile{
    if ([self fileExistsAtPath: self.currentPath]) {
        NSLog(@"SKIP '%@' (file %i)", self.currentFileName, _currentIndex);
        if (_currentIndex < self.fileNames.count -1) {
            _currentIndex++;
            self.currentFileName = self.fileNames[_currentIndex];
            [self downloadTSFile];
        }
        return;
    }
    
    self.currentDownloadType = kDownloadTypeTSFile;
    NSURL * URL = [NSURL URLWithString: self.URLString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod: @"GET"];
    NSString * cookieString = kCOOKIEString;
    [request addValue: cookieString forHTTPHeaderField: @"Cookie"];
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}

#pragma mark - Helper methods
- (NSString *) URLString{
    NSString * returnValue;
    if (self.tsFilePath){
        returnValue = [NSString stringWithFormat: @"%@%@/%@%@", kBaseURL, self.tsFilePath, self.currentFileName, kGETParamaters];
    } else{
        returnValue = [NSString stringWithFormat: @"%@%@%@", kBaseURL, self.currentFileName, kGETParamaters];
    }
    return returnValue;
}

- (NSString *) stringFromData: (NSData *) data{
    NSString * resultString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return resultString;
}

- (NSString *) currentPath{
    NSString * returnValue = [NSString stringWithFormat: @"%@%@", kBaseStorePath, self.currentFileName];
    return returnValue;
}

#pragma mark - Downloaded Data handlers
- (void) handleBandWithList: (NSData *) data{
    NSString * bandWidthList = [self stringFromData: data];
    NSArray * components     = [bandWidthList componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    NSPredicate * containsM3U8 = [NSPredicate predicateWithFormat: @"self CONTAINS %@", @"m3u8"];
    NSArray * filteredArray = [components filteredArrayUsingPredicate: containsM3U8];
    NSString * selectedBandWidth = [filteredArray lastObject];

    NSArray * bandWidthComponents = [selectedBandWidth componentsSeparatedByString: @"/"];
    
    self.tsFilePath = bandWidthComponents[0];
    self.currentFileName = bandWidthComponents[1];
    [self downloadTSFilesList];
}
- (void) handleStreamFilesList: (NSData *) data{
    NSString * streamFilesList  = [self stringFromData: data];
    NSArray  * components       = [streamFilesList componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    NSPredicate * containsDotTS = [NSPredicate predicateWithFormat: @"self CONTAINS %@", @".ts"];
    self.fileNames = [components filteredArrayUsingPredicate: containsDotTS];
    
    NSString * selectedFile = self.fileNames[0];
    self.currentFileName = selectedFile;
    
    [self downloadTSFile];
    
}
- (BOOL) fileExistsAtPath: (NSString *) path{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath: path];
}

- (void) handleTSFileData: (NSData *) data{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"--SAVED file '%@' (file %i)--", self.currentFileName, _currentIndex);
        [data writeToFile: self.currentPath atomically: YES];
    });
    
    if (_currentIndex < self.fileNames.count -1) {
        _currentIndex++;
        self.currentFileName = self.fileNames[_currentIndex];
        [self downloadTSFile];
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
    switch (self.currentDownloadType) {
        case kDownloadTypeBandWidthsList:
            [self handleBandWithList: _data];
            break;
        case kDownloadTypeStreamFilesList:
            [self handleStreamFilesList: _data];
            break;
        case kDownloadTypeTSFile:
            [self handleTSFileData: _data];
            break;
            
        default:
            break;
    }
    _data = nil;
    _expectedContentLength = 0;
    _cumulativeReveivedBytes = 0;
    self.progression = 0.0f;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    _data = nil;
    NSLog(@"%@, %@", error, [error localizedDescription]);
    
}
@end
