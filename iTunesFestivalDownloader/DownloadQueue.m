//
//  DownoadQueue.m
//  iTunesFestivalDownloader
//
//  Created by Joride on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import "DownloadQueue.h"

@interface DownloadQueue ()
@property (nonatomic, readonly) NSMutableSet * queuedDownloads;
@property (nonatomic, readonly) NSMutableSet * inProgressDownloads;
@end

@implementation DownloadQueue{
    dispatch_queue_t _queue;
}
@synthesize queuedDownloads = _queuedDownloads;
@synthesize inProgressDownloads = _inProgressDownloads;

+ (DownloadQueue *)sharedQueue{
    static DownloadQueue * sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownloadQueue alloc] init];
    });
    return sharedInstance;
}
- (id) init{
    self = [super init];
    if (self) {
        self.maxSimultaneousDownloads = 1;
        _queue = dispatch_queue_create("com.iTunesFestivalDownloader.DownloadQueue-queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Accessors
- (NSMutableSet *) queuedDownloads{
    if (_queuedDownloads == nil) {
        _queuedDownloads = [[NSMutableSet alloc] init];
    }
    return _queuedDownloads;
}
- (NSMutableSet *) inProgressDownloads{
    if (_inProgressDownloads == nil) {
        _inProgressDownloads = [[NSMutableSet alloc] initWithCapacity: self.maxSimultaneousDownloads];
    }
    return _inProgressDownloads;
}
- (void) setMaxSimultaneousDownloads:(NSInteger)maxSimultaneousDownloads{
    _maxSimultaneousDownloads = MAX(1, maxSimultaneousDownloads);
}
#pragma mark -
- (void) addDownloader: (FileDownloader *) downloader{
    dispatch_async(_queue, ^{
        [self.queuedDownloads addObject: downloader];
    });
    [self dequeue];
}

- (void) dequeue{
        // if there are not max allowed downloads currently, start another
        if (self.inProgressDownloads.count < (self.maxSimultaneousDownloads + 1)){
            
            FileDownloader * dequeuedDownloader = [self.queuedDownloads anyObject];
            if (dequeuedDownloader != nil){
                [self.queuedDownloads removeObject: dequeuedDownloader];
                [self.inProgressDownloads addObject: dequeuedDownloader];
                
                [dequeuedDownloader startDownloadWithCompletion:^(BOOL success) {
                    [self.inProgressDownloads removeObject: dequeuedDownloader];
                        [self dequeue];
         
                }];
            }
        }
}

@end
