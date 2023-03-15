//
//  SendStreamUtil.h
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/24.
//

#import <Foundation/Foundation.h>

@class AgoraRtcEngineKit;

NS_ASSUME_NONNULL_BEGIN

@interface SendStreamUtil : NSObject

+(void)sendStreamMsgWithAgoraRtc:(AgoraRtcEngineKit *)agoraKit uid:(int64_t) uid;

@end

NS_ASSUME_NONNULL_END
