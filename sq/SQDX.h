//
//  SQDX.h
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#ifndef SQDX_H
#define SQDX_H

@interface SQDX : NSObject

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error;
- (void)createJSON5WithError:(NSError **)error;
- (void)executeWithName:(NSString *)name options:(NSArray *)options error:(NSError **)error;
- (void)docsWithError:(NSError **)error;
- (void)version;

@end

#endif // SQDX_H
