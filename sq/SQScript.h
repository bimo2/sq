//
//  SQScript.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-20.
//

#ifndef SQSCRIPT_H
#define SQSCRIPT_H

@interface SQScript : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *info;
@property (nonatomic, copy, readonly) NSString *shell;
@property (nonatomic, readonly) NSArray *commands;

- (instancetype)initWithName:(NSString *)name info:(NSString *)info shell:(NSString *)shell commands:(NSArray *)commands;

@end

#endif // SQSCRIPT_H