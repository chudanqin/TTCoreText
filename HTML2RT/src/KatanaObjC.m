//
//  KatanaObjC.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/31.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "KatanaObjC.h"

void objc_appendKatanaQualifiedName(NSMutableString *str, KatanaQualifiedName *qn) {
    if (qn->prefix == NULL) {
        [str appendFormat:@"%s", qn->local];
    } else {
        [str appendFormat:@"%s|%s", qn->prefix, qn->local];
    }
}
