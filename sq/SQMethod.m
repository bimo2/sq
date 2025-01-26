//
//  SQMethod.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>

#import "SQMethod.h"

@implementation SQMethod

- (instancetype)initWithName:(NSString *)name info:(NSString *)info commands:(NSArray *)commands {
  _name = name;
  _info = info;
  _commands = commands.copy;

  return self;
}

@end
