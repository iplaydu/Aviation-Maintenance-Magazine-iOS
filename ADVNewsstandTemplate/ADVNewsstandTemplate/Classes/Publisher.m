//
//  Publisher.m
//  Newsstand
//
//  Created by Carlo Vigiani on 18/Oct/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//


#define CacheDataDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]


#import "Publisher.h"
#import <NewsstandKit/NewsstandKit.h>
#import "AppDelegate.h"

@interface Publisher ()


@end

@implementation Publisher 

@synthesize ready;

-(id)init {
    
    self = [super init];
    if(self) {
        ready = NO;
        self.issues = nil;
        
        NSLog(@"There IS internet connection");
        
        NSString *issuesCachePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Issues Cached"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:issuesCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:issuesCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    
    }
    
    return self;
}

-(void)getIssuesList {
    
    Repository* repo = [AppDelegate instance].repository;
    repo.delegate = self;
    
    [repo loadMagazineConfigurationFromServer];
    
}

-(void)didLoadMagazineConfigurationFromServerWithSuccess:(BOOL)success{
    
    if(success){
        Repository* repo = [AppDelegate instance].repository;
        
        self.issues = [IssueInfo loadIssuesFromConfigData:[repo magazineIssues]];    
        ready = YES;
        [self addIssuesInNewsstand];
    }
    
    [self.delegate didLoadIssuesWithSuccess:success];

}

-(void)addIssuesInNewsstand {
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    
    for (IssueInfo* issue in self.issues) {
        NSString *name = issue.uniqueId;
        NKIssue *nkIssue = [nkLib issueWithName:name];
        if(!nkIssue) {
            nkIssue = [nkLib addIssueWithName:name date:[NSDate date]];
        }
        
        issue.nkIssue = nkIssue;
        
        NSLog(@"Issue: %@",nkIssue);
    }
}

-(NSInteger)numberOfIssues {
    if([self isReady] && self.issues) {
        return [self.issues count];
    } else {
        return 0;
    }
}

-(IssueInfo *)issueAtIndex:(NSInteger)index {
    return [self.issues objectAtIndex:index];
}


-(NSInteger)indexOfIssue:(IssueInfo*)issueInfo {
    return [self.issues indexOfObject:issueInfo];
}

-(NSString *)titleOfIssueAtIndex:(NSInteger)index {
    return [[self issueAtIndex:index] title];
}

-(NSString *)idOfIssueAtIndex:(NSInteger)index {
    return [[self issueAtIndex:index] uniqueId];
}

-(void)setCoverOfIssueAtIndex:(NSInteger)index  completionBlock:(void(^)(UIImage *img))block {
    NSURL *coverURL = [NSURL URLWithString:[[self issueAtIndex:index] coverImageUrl]];
    
    NSString *coverFileName = [self getBothLastComponentsFromPath:[coverURL path]];
      
    NSString *coverFilePath = [CacheDataDirectory stringByAppendingPathComponent:coverFileName];
    UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
    if(image) {
        block(image);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^{
                           NSData *imageData = [NSData dataWithContentsOfURL:coverURL];
                           UIImage *image = [UIImage imageWithData:imageData];
                           if(image) {
                               [imageData writeToFile:coverFilePath atomically:YES];
                               block(image);
                           }
                       });
    }
}

-(UIImage *)coverImageForIssueAtIndex:(NSInteger)index{
    
    IssueInfo* issueInfo = [self.issues objectAtIndex:index];
    NSString *coverPath = [issueInfo coverImageUrl];
    NSString *coverName = [self getBothLastComponentsFromPath:coverPath];
    NSString *coverFilePath = [CacheDataDirectory stringByAppendingPathComponent:coverName];
    UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
    return image;
}

-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue {
    NSString *name = nkIssue.name;
    for(IssueInfo *issueInfo in self.issues) {
        if([name isEqualToString:[issueInfo uniqueId]]) {
            NSString *coverPath = [issueInfo coverImageUrl];
            NSString *coverName = [self getBothLastComponentsFromPath:coverPath];
            NSString *coverFilePath = [CacheDataDirectory stringByAppendingPathComponent:coverName];
            UIImage *image = [UIImage imageWithContentsOfFile:coverFilePath];
            return image;
        }
    }
    return nil;
}

-(NSString*)getBothLastComponentsFromPath:(NSString*)path
{
    NSString *filePath = [path lastPathComponent];
    NSArray* components = [path pathComponents];
    if([components count] > 1)
    {
        int count = [components count];
        filePath = [NSString stringWithFormat:@"%@%@", [components objectAtIndex:count - 2], [components objectAtIndex:count - 1]];
    }

    return filePath;
}

-(NSURL *)contentURLForIssueWithName:(NSString *)name {
    __block NSURL *contentURL=nil;
    [self.issues enumerateObjectsUsingBlock:^(IssueInfo* obj, NSUInteger idx, BOOL *stop) {
        NSString *aName = [obj uniqueId];
        if([aName isEqualToString:name]) {
            contentURL = [NSURL URLWithString:[obj contentUrl]];
            *stop=YES;
        }
    }];
    NSLog(@"Content URL for issue with name %@ is %@",name,contentURL);
    return contentURL;
}

-(void)fetchStoreInfoForIssue:(IssueInfo*)issueInfo{
    
   // [AppDelegate instance].storeManager
}
@end
