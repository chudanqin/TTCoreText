//
//  TTLabel.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/19.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTextSlice.h"

@interface TTLabel : UIView

@property (nonatomic, strong) TTTextSlice *textSlice;

@property (nonatomic, assign) NSTimeInterval fadeDurationOnAayncDisplay;

@end
