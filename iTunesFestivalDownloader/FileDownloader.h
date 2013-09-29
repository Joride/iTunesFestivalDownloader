//
//  FileDownloader.h
//  iTunesFestivalDownloader
//
//  Created by Joride on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileDownloader : NSObject


- (id) initWithFileName: (NSString *) fileName
               savePath: (NSString *) savePath
                    URL: (NSString *) URL
                   date: (NSString *) date
             remotePath: (NSString *) remotePath
          GETParameters: (NSString *) GETParameters
                 cookie: (NSString *) cookie;

- (void) startDownloadWithCompletion: ( void(^)(BOOL success)) completion;
@end
