//
//  TableViewDataSource.h
//  Core
//
//  Created by Armen Mkrtchian on 25/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableViewDataSourceDelegate <NSObject>

- (void)currentCellRowNumber:(NSInteger)rownumber;

@end

typedef void (^TableViewCellBlock)(id cell, id item);

@interface TableViewDataSource : NSObject <UITableViewDataSource>
// property
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign) id<TableViewDataSourceDelegate> delegate;

// method
- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)configureCellBlock;

- (void)setItems:(NSMutableArray *)items;

- (NSIndexPath *)indexOfObject:(id)anObject;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (void)removeItem:(id)item;

- (void)removeItemAtIndex:(NSIndexPath *)indexPath;

@end
