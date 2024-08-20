//
//  SQScript.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-20.
//

#import <Foundation/Foundation.h>

#import "SQScript.h"

@implementation SQScript

- (instancetype)initWithName:(NSString *)name info:(NSString *)info shell:(NSString *)shell commands:(NSArray *)commands {
    _name = name;
    _info = info;
    _shell = shell;
    _commands = [commands copy];
    
    return self;
}

@end
