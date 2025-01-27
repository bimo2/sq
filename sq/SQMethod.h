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
@property (nonatomic, readonly) NSArray *commands;

- (instancetype)initWithName:(NSString *)name info:(NSString *)info commands:(NSArray *)commands;
- (NSString *)signature;

@end

#endif // SQMETHOD_H
