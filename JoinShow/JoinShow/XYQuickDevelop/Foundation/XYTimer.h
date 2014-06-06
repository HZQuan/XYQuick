//
//  XYTimer.h
//  JoinShow
//
//  Created by Heaven on 13-9-8.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#pragma mark - #define

#undef	NSObject_XYTimers
#define NSObject_XYTimers	"NSObject.XYTimer.XYTimers"

#import "XYPrecompile.h"


#pragma mark - #define

#undef	ON_TIMER
#define ON_TIMER( __name ) \
        -(void) __name##TimerHandle:(NSTimer *)Timer time:(NSTimeInterval)time

typedef void(^XYTimer_block)(NSTimer *timer, NSTimeInterval time);

#pragma mark - XYTimer
@interface XYTimer : NSObject

@property (nonatomic ,strong) NSTimer *timer;

@end

#pragma mark - NSObject(XYTimer)
@interface NSObject (XYTimer)

@property (nonatomic, readonly, strong) NSMutableDictionary *XYtimers;

-(NSTimer *) timer:(NSTimeInterval *)interval;
-(NSTimer *) timer:(NSTimeInterval *)interval repeat:(BOOL)repeat;
-(NSTimer *) timer:(NSTimeInterval *)interval repeat:(BOOL)repeat name:(NSString *)name;

-(void) cancelTimer:(NSString *)name;
-(void) cancelAllTimer;

@end

#pragma mark - 
// CADisplayLink
// Ticker


#pragma mark - #define

#undef	ON_TICK
#define ON_TICK( __time ) \
-(void) handleTick:(NSTimeInterval)__time

#pragma mark - XYTicker
/**
 * 说明
 * XYTicker 采用用一个CADisplayLink计时, 不用的时候需要手动移除观察
 */
@interface XYTicker : NSObject

@property (nonatomic, weak, readonly) CADisplayLink *timer;
@property (nonatomic, assign, readonly)	NSTimeInterval		timestamp;
@property (nonatomic, assign) NSTimeInterval		interval;

AS_SINGLETON( XYTicker )

-(void) addReceiver:(NSObject *)obj;
-(void) removeReceiver:(NSObject *)obj;

@end

@interface NSObject(XYTicker)

-(void) observeTick;
-(void) unobserveTick;
-(void) handleTick:(NSTimeInterval)elapsed;

@end











