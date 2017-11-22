//
//  StudentInfo.h
//  SQLiteDatabaseExample
//
//  Created by Administrator on 11/21/17.
//  Copyright © 2017 Albert Diaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentInfo : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *address;
@property (nonatomic, strong)NSString *phone;
-(id)initWithData:(NSString *)n andAddress:(NSString* )a andPhone:(NSString *)p;

@end
