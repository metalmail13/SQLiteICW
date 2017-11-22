//
//  StudentInfo.m
//  SQLiteDatabaseExample
//
//  Created by Administrator on 11/21/17.
//  Copyright © 2017 Albert Diaz. All rights reserved.
//

#import "StudentInfo.h"

@implementation StudentInfo
-(id)initWithData:(NSString *)n andAddress:(NSString* )a andPhone:(NSString *)p
{
    if(self == [super init])
    {
        [self setName:n];
        [self setAddress:a];
        [self setPhone:p];
    }
    
    return self;
}
@end
