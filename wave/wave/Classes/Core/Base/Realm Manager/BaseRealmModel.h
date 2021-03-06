//
//  BaseRealmModel.h
//  Core
//
//  Created by Armen Mkrtchian on 17/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

@import Realm;

@interface BaseRealmModel : RLMObject

@property BOOL dirty;
@property long updateTime;

- (void)saveInDefaultRealm;
- (void)saveInRealm:(RLMRealm *)realm;

- (void)createOrUpdateInDefaultRealm;
- (void)createOrUpdateInRealm:(RLMRealm *)realm;

+ (void)removeAllObjects;

- (instancetype)initWithModel:(id)model;
- (instancetype)initWithType:(NSString *)type value:(NSString *)value;

- (RLMArray *)populateData:(RLMArray *)array className:(NSString *)className;
- (RLMArray *)populateData:(RLMArray *)array className:(NSString *)className type:(NSString *)type;
@end
