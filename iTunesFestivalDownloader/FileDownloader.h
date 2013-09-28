//
//  FileDownloader.h
//  iTunesFestivalDownloader
//
//  Created by Jorrit van Asselt on 28-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloader : NSOperation
@property (nonatomic, copy)     NSString    * tsFileName;
@property (nonatomic)           CGFloat     progression;
@property (nonatomic, copy)     NSString    * storePath;
@property (nonatomic, copy)     NSString    * fileName;
@property (nonatomic, copy)     NSString    * URLString;
@property (nonatomic, copy)     NSString    * tsFilePath;
@property (nonatomic, copy)     NSString    * cookieString;

@end
