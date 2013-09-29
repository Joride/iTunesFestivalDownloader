//
//  DownloadQueue.h
//  iTunesFestivalDownloader
//
//  Created by Joride on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloader.h"

@interface DownloadQueue : NSObject
// defaults to 1
@property (nonatomic) NSInteger maxSimultaneousDownloads;

+ (DownloadQueue *) sharedQueue;
- (void) addDownloader: (FileDownloader *) downloader;
@end
