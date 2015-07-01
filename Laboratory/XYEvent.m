//
//  XYEvent.m
//  JoinShow
//
//  Created by XingYao on 15/7/1.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import "XYEvent.h"
#import "XYQuick.h"

#pragma mark -XYEventVO
@interface XYEventVO : NSObject

@property (nonatomic, copy) NSString *event;
@property (nonatomic, strong) id target;        // 先用strong测试, 记得修改
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) void(^block)(void);

@property (nonatomic, weak) XYEventVO *nextResponder;

- (void)invoke;

@end

@implementation XYEventVO

- (void)invoke
{
    [_target performSelectorInBackground:_action withObject:nil];
}
@end

#pragma mark-

@interface XYEventOperation : NSOperation
@property (nonatomic, copy, readonly) NSString *mark;
@property (nonatomic, assign) NSTimeInterval second;
@property (nonatomic, strong) XYEventVO *vo;
@end

@implementation XYEventOperation
- (instancetype)initWithEventVO:(XYEventVO *)vo time:(NSTimeInterval)second
{
    self = [super init];
    if (self) {
        _vo = vo;
        _second = second;
    }
    return self;
}
- (void)main
{
    @autoreleasepool
    {
        sleep(_second);
        [_vo invoke];
        NSLog(@"%@, %f", _vo.event, _second);
    }
}
- (void)dealloc
{
    NSLog(@"%@, dealloc", _vo.event);
}

@end

#pragma mark -XYEventCenter
@interface XYEventCenter ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *eventInfos;

@end

@implementation XYEventCenter

+ (instancetype)defaultCenter
{
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

- (void)addTarget:(id)target action:(SEL)action forEvents:(NSString *)events
{
#ifdef DEBUG
    NSAssert((target != nil), @"error");
    NSAssert([target respondsToSelector:action], @"error");
    NSAssert((events.length != 0), @"error");
#else
    if (target == nil) return;
    if (![target respondsToSelector:action]) return;
    if (events.length == 0) return;
#endif
    
    NSMutableArray *mArray = self.eventInfos[events] ?: [@[] mutableCopy];
    
    XYEventVO *vo = [[XYEventVO alloc] init];
    vo.target = target;
    vo.action = action;
    vo.event = events;
    
    ((XYEventVO *)[mArray lastObject]).nextResponder = vo;
    
    [mArray addObject:vo];
    self.eventInfos[events] = mArray;
}

- (void)sendActionsForEvents:(NSString *)events
{
#ifdef DEBUG
    NSAssert((events.length != 0), @"error");
#else
    if (events.length == 0) return;
#endif
    NSMutableArray *mArray = self.eventInfos[events];
    [mArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XYEventVO *vo = obj;
        XYEventOperation *op = [[XYEventOperation alloc] initWithEventVO:vo time:1];
        [self.operationQueue addOperation:op];
    }];
}

#pragma mark- getter setter
- (NSOperationQueue *)operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 5;
    };
    return _operationQueue;
}
- (NSMutableDictionary *)eventInfos
{
    if (_eventInfos == nil)
    {
        _eventInfos = [@{} mutableCopy];
    }
    return _eventInfos;
}
@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if (1 == __XY_DEBUG_UNITTESTING__)

UXY_TEST_CASE( Core, XYEventCenter )
{
    //	TODO( "test case" )
}

UXY_DESCRIBE( test1 )
{
    //  UXY_EXPECTED( 1 == 1 );
    //  UXY_EXPECTED( [@"123" isEqualToString:@"123"] );
   // [[XYEventCenter defaultCenter] sendActionsForEvents:@"1"];
}

UXY_DESCRIBE( test2 )
{
    //  UXY_EXPECTED( 1 == 1 );
    //  UXY_EXPECTED( [@"123" isEqualToString:@"123"] );
    XYEventCenter *center = [XYEventCenter defaultCenter];
    [center addTarget:self action:@selector(doSomething) forEvents:@"a"];
    [center sendActionsForEvents:@"a"];
    [center sendActionsForEvents:@"a"];
    [center sendActionsForEvents:@"a"];
}

UXY_DESCRIBE( test3 )
{
    // UXY_EXPECTED( [@"123" isEqualToString:@"123456"] );
}

- (void)doSomething
{
    NSLog(@"%s", __func__);
}

UXY_TEST_CASE_END

#endif

