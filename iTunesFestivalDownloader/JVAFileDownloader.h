//
//  JVAFileDownloader.h
//  iTunesFestivalDownloader
//
//  Created by Jorrit van Asselt on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JVAFileDownloader : NSObject


- (id) initWithFileName: (NSString *) fileName
               savePath: (NSString *) savePath
                    URL: (NSString *) URL
                   date: (NSString *) date
             remotePath: (NSString *) remotePath
          GETParameters: (NSString *) GETParameters
                 cookie: (NSString *) cookie
             completion: ( void(^)(BOOL success)) completion;

- (void) startDownload;
@end
