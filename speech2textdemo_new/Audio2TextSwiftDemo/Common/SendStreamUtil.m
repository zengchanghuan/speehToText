//
//  SendStreamUtil.m
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/24.
//

#import "SendStreamUtil.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Audio2TextProtobuffer.pbobjc.h"

@implementation SendStreamUtil

+(void)sendStreamMsgWithAgoraRtc:(AgoraRtcEngineKit *)agoraKit uid:(int64_t) uid {
    static NSInteger msgid = 0;
    if (0 == msgid) {
        int ret = [agoraKit createDataStream:&msgid reliable:false ordered:false];
        if (0 != ret) {
            NSLog(@" createDataStream failed %@", @(ret));
        }
        //        [self.rtcEngineKit setParameters:@"{\"rtc.datastream_max_br\":600,\"rtc.datastream_max_packrate\":200}"];
    }
    
    static uint64_t s_nCount = 1;
    char l_szFormat[1024];
    int64_t l_nTotalSecond = [[NSDate date] timeIntervalSince1970] * 1000;
    //fill seq+timestamp +padding
    memcpy(l_szFormat, &s_nCount, 4);
    memcpy(l_szFormat + 4, &l_nTotalSecond, 8);
    memcpy(l_szFormat + 12, "hello what is your name", 12);
    s_nCount++;
    
//    NSString *params = @"{\"audio\": {\"subscribeSource\": \"AGORARTC\",\"agoraRtcConfig\": {\"channelName\": \"\(channelName)\",\"uid\": \"\(uid)\",\"token\": \"\(token)\",\"channelType\": \"\(channelType)\",\"subscribeConfig\": {\"subscribeMode\": \"CHANNEL_MODE\"},\"maxIdleTime\": 600}},\"config\": {\"features\": [\"RECOGNIZE\"],\"recognizeConfig\": {\"language\": \"ENG\",\"model\": \"Model\",\"connectionTimeout\": 60,\"output\": {\"destinations\": [\"AgoraRTCDataStream\"],\"agoraRTCDataStream\": {\"channelName\": \"\(channelName)\",\"uid\": \"\(uid)\",\"token\": \"\(token)\"}}}}}";
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:&error];
    Word *w1 = [[Word alloc] init];
    w1.text = @"abcef jdlajd lsjdlajd dlajdf";
    w1.isFinal = false;
    
    Word *w2 = [[Word alloc] init];
    w2.text = @"what is your name ? i am fine too";
    w2.isFinal = true;
    
    Word *w3 = [[Word alloc] init];
    w3.text = @"how do you do?";
    w3.isFinal = true;
    
    NSMutableArray *wardArray = [NSMutableArray array];
    [wardArray addObject:w1];
    if (arc4random() % 2 == 0) {
        [wardArray addObject:w2];
    }
    if (arc4random() % 2 == 0) {
        [wardArray addObject:w3];        
    }
    
    Text *t = [[Text alloc] init];
    t.wordsArray = wardArray;
    t.uid = uid;
    
    NSLog(@"wardArray == %@",wardArray);
    
    int ret = [agoraKit sendStreamMessage:msgid data:t.data];
//    int ret = [agoraKit sendStreamMessage:msgid data:[NSData dataWithBytes:l_szFormat length:24]];
    if (0 != ret) {
        NSLog(@" sendStreamMessage streammessage failed %@", @(ret));
    }else {
        NSLog(@" sendStreamMessage streammessage success");
    }
}

@end
