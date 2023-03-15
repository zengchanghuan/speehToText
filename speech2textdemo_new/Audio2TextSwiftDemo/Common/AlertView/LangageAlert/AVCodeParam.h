//
//  AVCodeParam.h
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCodeParam : NSObject

@property (nonatomic, copy) NSString *mInFileUrl;

@property (nonatomic, assign) int mOutVidFormat;

@property (nonatomic, assign) int mOutVidWidth;

@property (nonatomic, assign) int mOutVidHeight;

@end

NS_ASSUME_NONNULL_END
