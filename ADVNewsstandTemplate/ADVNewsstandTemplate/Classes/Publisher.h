//
//  Publisher.h
//  Newsstand
//
//  Created by Carlo Vigiani on 18/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#import "Repository.h"
#import "IssueInfo.h"
#import "StoreManager.h"

@protocol PublisherDelegate;

@interface Publisher : NSObject <RepositoryDelegate>{
    
}

@property (nonatomic,readonly,getter = isReady) BOOL ready;

@property (nonatomic, strong) NSArray *issues;

@property (nonatomic, assign) id<PublisherDelegate> delegate;

-(void)addIssuesInNewsstand;
-(void)getIssuesList;
-(NSInteger)numberOfIssues;
-(NSString *)titleOfIssueAtIndex:(NSInteger)index;
-(NSString *)idOfIssueAtIndex:(NSInteger)index;
-(void)setCoverOfIssueAtIndex:(NSInteger)index completionBlock:(void(^)(UIImage *img))block;
-(NSURL *)contentURLForIssueWithName:(NSString *)name;
-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue;
-(UIImage *)coverImageForIssueAtIndex:(NSInteger)index;
-(IssueInfo *)issueAtIndex:(NSInteger)index;
-(NSInteger)indexOfIssue:(IssueInfo*)issueInfo;
-(NSString*)getBothLastComponentsFromPath:(NSString*)path;

-(void)didLoadMagazineConfigurationFromServerWithSuccess:(BOOL)success;

@end

@protocol PublisherDelegate <NSObject>

-(void)didLoadIssuesWithSuccess:(BOOL)success;

@end
