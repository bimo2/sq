//
//  SQDX.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#import <Foundation/Foundation.h>
#import "define.h"

#import "SQDX.h"

@interface SQDX ()

@property (nonatomic, copy, readonly) NSString *path;

@end

@implementation SQDX

- (instancetype)initWithPath:(NSString *)path {
  _path = path;

  return self;
}

- (void)version {
  NSString *version = [NSString stringWithFormat:@"%s (%s)", VERSION, COMMIT_SHA];

  PRINT(version.UTF8String);
}

@end
