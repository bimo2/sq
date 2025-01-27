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
- (void)json5WithFileManager:(NSFileManager *)fileManager error:(NSError **)error;
- (void)docs;
- (void)version;

@end

#endif // SQDX_H
