//
//  TTAtomicDef.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/20.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#ifndef TTAtomicDef_h
#define TTAtomicDef_h

#if __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_12 || __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
#import <stdatomic.h>
#define TTAtomicIncrement32(v)   atomic_fetch_add((atomic_int_fast32_t *)v, 1)
#else
#import <libkern/OSAtomic.h>
#define TTAtomicIncrement32(v)   OSAtomicIncrement32(v)
#endif

#define TTSemaphoreLock(semaphore, ...) dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); { __VA_ARGS__ } dispatch_semaphore_signal(semaphore);

#endif /* TTAtomicDef_h */
