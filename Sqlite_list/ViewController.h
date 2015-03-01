//
//  ViewController.h
//  Sqlite_list
//
//  Created by benlu on 2/11/14.
//  Copyright (c) 2014 benlu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    //變數db,型別是db
    sqlite3* db;
    //變數TabelDatas，型別是NSMutableArray
    NSMutableArray *TabelDatas;
}

@property (weak, nonatomic) IBOutlet UITextField *mytitle;
@property (weak, nonatomic) IBOutlet UITextField *mydetail;
@property (weak, nonatomic) IBOutlet UITableView *mytable;

//宣告新增按鈕方法insertdata
- (IBAction)insertdata:(id)sender;
//宣告查詢按鈕方法querydata
- (IBAction)querydata:(id)sender;

//宣告executeQuery方法，帶入SQL字串，傳回一個sqlite3_stmt物件
- (sqlite3_stmt *) executeQuery:(NSString *) query;
//宣告statementtoMSarray方法，帶入sqlite3_stmt物件，傳回一個NSMutableArray物件
- (NSMutableArray *) statementtoMSarray:(sqlite3_stmt *) sqlstmt;



@end
