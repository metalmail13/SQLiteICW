//
//  ViewController.m
//  SQLiteDatabaseExample
//
//  Created by Administrator on 11/21/17.
//  Copyright © 2017 Albert Diaz. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "StudentInfo.h"

@interface ViewController ()
@property (nonatomic, strong)NSString *databaseName;
@property (nonatomic, strong)NSString *databasePath;
@property (nonatomic, strong)NSMutableArray *people;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.people = [[NSMutableArray alloc]init];
    self.databaseName = @"MyStudents.db";
    
    // Find path to documents folder
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDir = [documentPath objectAtIndex:0];
    self.databasePath = [documentsDir stringByAppendingPathComponent:self.databaseName];
 
    // Copy DB to App
    [self copyDatabaseToDocumentsDirectory];
    
    // Retrieve data from DB
    [self readFromDatabase];
}

-(void)readFromDatabase
{
    // Clear the array
    [self.people removeAllObjects];
    
    sqlite3 *database;
    
    // Open DB
    if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK)
    {
        // Create a Query
        char *sqlStatement = "select * from students";
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step
                  (compiledStatement) ==
                  SQLITE_ROW){
                char *n = (char *)sqlite3_column_text(compiledStatement, 1);
                char *a = (char *)sqlite3_column_text(compiledStatement, 2);
                char *p = (char *)sqlite3_column_text(compiledStatement, 3);
                
                NSString* name = [NSString stringWithUTF8String:n];
                NSString* address = [NSString stringWithUTF8String:a];
                NSString* phone = [NSString stringWithUTF8String:p];
                
                StudentInfo *aStudent = [[StudentInfo alloc] initWithData:name andAddress:address andPhone:phone];
                [self.people addObject: aStudent];
            }
        }
        
        // free the allocated memory
        sqlite3_finalize(compiledStatement);
    }
    
    // close the db connection
    sqlite3_close(database);
}

-(void)copyDatabaseToDocumentsDirectory
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:self.databasePath];
    if(success)
        return;
    
    // if this is our first time using the app we need to copy the database from app's bundle to docs directory
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:self.databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
    
}

-(BOOL)insertIntoDatabase:(StudentInfo *)aStudent{
    sqlite3 *database;
    
    BOOL returnCode = YES;
    
    if(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK ){
        
        char * sqlStatement = "insert into students values(NULL, ?, ?, ?)";
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK){
            sqlite3_bind_text(compiledStatement, 1, [aStudent.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 2, [aStudent.address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 3, [aStudent.phone UTF8String], -1, SQLITE_TRANSIENT);
            
            //run the query
            if (sqlite3_step(compiledStatement)!= SQLITE_DONE){
                NSLog(@"Error %s", sqlite3_errmsg(database));
                returnCode = NO;
            }else{
                NSLog(@"Inserted into row id: %lld", sqlite3_last_insert_rowid(database));
            }
            
            // Cleanup
            sqlite3_finalize(compiledStatement);
        }
    }
    // Close the db
    sqlite3_close(database);
    
    return returnCode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addRecord:(UIButton *)sender {
    StudentInfo *person = [[StudentInfo alloc] initWithData:self.txtName.text andAddress:self.txtAddress.text andPhone:self.txtPhone.text];
    BOOL retCode = [self insertIntoDatabase:person];
    if(retCode == NO){
        NSLog(@"Failed to add a record");
        self.lblStatus.text = @"Failed to add  record";
    }else{
        NSLog(@"Added a record successfully");
        self.lblStatus.text = @"Added a record successfully";
    }
}

-(void)findRecordInDatabase{
    
    sqlite3 *database;
    
    // Open DB
    if (sqlite3_open([self.databasePath UTF8String],&database) == SQLITE_OK)
    {
        // Create a Query
        NSString *selectSQL = [NSString stringWithFormat:@"Select address, phone from students where name = '%@'", self.txtName.text];
        char *sqlStatement = (char *)[selectSQL UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step
                  (compiledStatement) ==
                  SQLITE_ROW){
                char *a = (char *)sqlite3_column_text(compiledStatement, 0);
                char *p = (char *)sqlite3_column_text(compiledStatement, 1);
                
                NSString* address = [NSString stringWithUTF8String:a];
                NSString* phone = [NSString stringWithUTF8String:p];
                
                // update labels
                self.txtAddress.text = address;
                self.txtPhone.text = phone;
                self.lblStatus.text = @"Match found";
            }
            else{
                self.lblStatus.text = @"Match not found";
            }
        }
        
        // free the allocated memory
        sqlite3_finalize(compiledStatement);
    }
    
    // close the db connection
    sqlite3_close(database);
}

-(void)deleteFromDB{
    
}

- (IBAction)findRecord:(UIButton *)sender {
    [self findRecordInDatabase];
}
- (IBAction)deleteRecord:(UIButton *)sender {
    
    
}


@end
