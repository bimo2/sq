//
//  define.h
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#ifndef DEFINE_H
#define DEFINE_H

#define SQ_FILE ".sq"

#define PRINT(cstring) printf("%s\n", cstring)
#define PRINT_SQ(cstring) printf("\033[1msq\033[0m %s\n", cstring)
#define PRINT_INFO(cstring, cstring1) printf("\033[1m%s\033[0m %s\n", cstring, cstring1)
#define PRINT_TIME(double) printf("\033[1;92m\u2713\033[0;92m %.3fs\033[0m\n", double)
#define PRINT_ERROR(cstring) printf("\033[1;91m\u2717\033[0;91m %s\033[0m\n", cstring)

#endif // DEFINE_H
