//
//  SQMethod.h
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#ifndef SQMETHOD_H
#define SQMETHOD_H

@interface SQMethod : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *info;
@property (nonatomic, copy, readonly) NSString *shell;
@property (nonatomic, readonly) NSArray *commands;

- (instancetype)initWithName:(NSString *)name info:(NSString *)info shell:(NSString *)shell commands:(NSArray *)commands;
- (NSString *)signature;
- (NSSet *)variables;
- (NSArray *)replaceWithOptions:(NSArray *)options secrets:(NSDictionary *)secrets error:(NSError **)error;

@end

#endif // SQMETHOD_H
