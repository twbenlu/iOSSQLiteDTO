//
//  ViewController.m
//  Sqlite_list
//
//  Created by benlu on 2/11/14.
//  Copyright (c) 2014 benlu. All rights reserved.
//

#import "ViewController.h"
#import "Conutry.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //把UITableView的dataSource及delegate委派給自己
    self.mytable.dataSource = self;
    self.mytable.delegate = self;
    
    NSString *dst = [NSString stringWithFormat:@"%@/Documents/test.sqlite",NSHomeDirectory()];
    if(sqlite3_open([dst UTF8String], &db) != SQLITE_OK){
        db = nil;
        NSLog(@"資料庫連線失敗");
    }else{
        NSLog(@"資料庫連線成功");
    }
}

//新增按鈕事件：將資料寫進SQLite資料庫
- (IBAction)insertdata:(id)sender{
//    NSString *sql = [NSString stringWithFormat:@"INSERT INTO country (engname,chname) VALUES ('%@','%@')",self.mytitle.text,self.mydetail.text];
//    char *errMsg;
//    if(sqlite3_exec(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errMsg) == SQLITE_OK){
//        NSLog(@"寫入資料庫成功, %s", errMsg);
//    }else{
//        NSLog(@"寫入資料庫失敗, %s", errMsg);
//    }
////    NSString *sql2 = [NSString stringWithFormat:@"select * from test"];
////    sqlite3_stmt *statement = [self executeQuery:sql2];
////    TabelDatas = [self statementtoMSarray:statement];
////    [self.mytable reloadData];
//    NSLog(@"寫入按鈕執行完成");
    
    sqlite3_stmt *stmt;
    //建立新增指令
    char *sql = "INSERT INTO country (engname,chname) VALUES (?,?);";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) {
            //真正建立資料庫的指令
            NSString * engname = self.mytitle.text;
            NSString * chname = self.mydetail.text;
        
            //綁定真正要寫入資料庫的值
            sqlite3_bind_text(stmt, 1, [engname UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [chname UTF8String], -1, NULL);

            if (sqlite3_step(stmt) != SQLITE_DONE) // ALWAYS RETURNS Error: NULL
                NSLog(@"Error updating table: %s", sqlite3_errmsg(db));
            sqlite3_reset(stmt);
    }
        //清除sqlite3_stmt物件
        sqlite3_finalize(stmt);
    
}


////查詢按鈕事件：將資料庫的資料撈出來
//- (IBAction)querydata:(id)sender{
//    //    //傳入資料庫查詢指令，下一個章節再來討論sql injection的問題
//
//    //建立查詢語法
//    NSString* safeSqlString =[NSString stringWithFormat:@"select * from country where engname = ?"];
//    //建立條件參數
//    NSString* engname = [NSString stringWithFormat:@"%@",self.mytitle.text];
//    //建立sqlite3_stmt物件
//    sqlite3_stmt* statement;
//    if (sqlite3_prepare_v2(db, [safeSqlString UTF8String], -1, &statement,nil) == SQLITE_OK) {
//        //置換綁定的參數值
//        if(sqlite3_bind_text(statement, 1, [engname UTF8String], -1, NULL) != SQLITE_OK)
//        {//Error Handling Code
//            NSAssert1(0,@"code1%s",sqlite3_errmsg(db));
//            sqlite3_finalize(statement);
//            return;
//        }
//        sqlite3_reset(statement);
//        TabelDatas = [self statementtoMSarray:statement];
//        [self.mytable reloadData];
//        
//    } else {
//        
//        NSLog(@"%s",sqlite3_errmsg(db));
//    }
//    sqlite3_finalize(statement);
//}



//查詢按鈕事件：將資料庫的資料撈出來
- (IBAction)querydata:(id)sender{
    //傳入資料庫查詢指令，下一個章節再來討論sql injection的問題
    NSString *sql2 = [NSString stringWithFormat:@"select * from country where engname = %@",self.mytitle.text];
    NSLog(@"%@",sql2);
    sqlite3_stmt *statement = [self executeQuery:sql2];
    TabelDatas = [self statementtoMSarray:statement];
    [self.mytable reloadData];
}


//宣告executeQuery方法，帶入SQL字串，傳回一個sqlite3_stmt物件
- (sqlite3_stmt *) executeQuery:(NSString *) query{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil);
    return statement;
}

//宣告statementtoMSarray方法，帶入sqlite3_stmt物件，傳回一個NSMutableArray物件
- (NSMutableArray*) statementtoMSarray:(sqlite3_stmt *) sqlstmt{
    //建立 NSMutableArray TabelDatas Instance;
    TabelDatas = [[NSMutableArray alloc]init];

    //利用回圈把sqlstmt裡面的資料取出來
    while (sqlite3_step(sqlstmt) == SQLITE_ROW) {
        //建立Conutry物件
        Conutry *test = [[Conutry alloc]init];
        //將sqlite3_stmt裡的資料對應Conutry物件屬性
        test.engname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlstmt,0)];
        test.chname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlstmt,1)];
        //將物件新增進動態陣列
        [TabelDatas addObject:test];
    }
    return TabelDatas;
}


//        str1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlstmt,0)];



//這個方法是用來指定UITableView有多少的Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

//這個方法是用來指定UITableView每個Section裡面有多少Rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    return 1;
    return [TabelDatas count];
}

//UITableView用來產生Cell的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //Configure the cell.
//  cell.textLabel.text = [[TabelDatas objectAtIndex:0]objectAtIndex:[indexPath row]];
//  cell.detailTextLabel.text  = [[TabelDatas objectAtIndex:1]objectAtIndex:[indexPath row]];
   
 
    //將TabelDatas陣列裡面物件取出
    Conutry *currentdata = [TabelDatas objectAtIndex:[indexPath row]];
    //接著就可以用物件屬性的方式來操作物件
    cell.textLabel.text = currentdata.engname;
    cell.detailTextLabel.text = currentdata.chname;

    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
