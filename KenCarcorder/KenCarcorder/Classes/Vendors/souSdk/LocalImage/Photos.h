//
//  Photos.h
//  Sample
//
//  Created by Kirby Turner on 2/10/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotosDelegate;

@interface Photos : NSObject {
   NSString *documentPath_;
   NSString *photosPath_;
   NSString *thumbnailsPath_;
   
   NSMutableArray *fileNames_;
   NSMutableDictionary *photoCache_;
   NSMutableDictionary *thumbnailCache_;
   
   NSOperationQueue *queue_;
}

@property (nonatomic, strong) id<PhotosDelegate> delegate;

- (NSString *)getPhotoPath;
- (int)FileSize;
- (void)flushCache;
- (void)savePhoto:(UIImage *)photo withName:(NSString *)name addToPhotoAlbum:(BOOL)addToPhotoAlbum;

@end


@protocol PhotosDelegate <NSObject>
@optional
- (void)didFinishSave;
- (void)exportImageAtPath:(NSString *)path;

@end