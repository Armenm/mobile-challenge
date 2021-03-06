//
//  TableViewDataSource.m
//  Core
//
//  Created by Armen Mkrtchian on 25/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "TableViewDataSource.h"

@interface TableViewDataSource ()
//Property
//@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellBlock configureCellBlock;

@end

@implementation TableViewDataSource

- (instancetype)initWithItems:(NSMutableArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = anItems;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (void)setItems:(NSMutableArray *)items
{
    _items = [items mutableCopy];
}

- (NSIndexPath *)indexOfObject:(id)anObject {
    
    NSIndexPath *indexPath;
    NSInteger section = 0;
    
    NSUInteger row = [self.items indexOfObject:anObject];
    if (row != NSNotFound) {
        
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    }
    
    return indexPath;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = nil;
    if (indexPath && indexPath.row < [self.items count]) {
        item = self.items[(NSUInteger) indexPath.row];
    }
    return item;
}

- (void)removeItem:(id)item {
    if([self.items containsObject:item]){
        [self.items removeObject:item];
    }
}

- (void)removeItemAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count]) {
        [self.items removeObjectAtIndex:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"index: %li", (long)indexPath.row);
    
    id item = [self itemAtIndexPath:indexPath];
    
    NSString *cellIdentifier = self.cellIdentifier;
    if ([item respondsToSelector:@selector(cellIdentifier)]) {
        
        if ([cellIdentifier isKindOfClass:[NSString class]] && [item cellIdentifier] != nil) {
        
            cellIdentifier = [item cellIdentifier];
        }
    }
    
    id cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item);
    }
    
    if ([self.delegate respondsToSelector:@selector(currentCellRowNumber:)]) {
        
        [self.delegate currentCellRowNumber:indexPath.row];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [NSArray array];
//}
@end
