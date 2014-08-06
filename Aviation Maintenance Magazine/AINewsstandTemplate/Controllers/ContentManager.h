//
//  ContentManager.h
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 10.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>



@protocol ContentManagerDelegate <NSObject>

-(void)didLoadContent:(BOOL)success;

@end
@interface ContentManager : NSObject

@property (nonatomic,assign) id<ContentManagerDelegate> delegate;
@property NSString* magazineTitle;
@property NSArray*  issues;
@property NSArray*  slides;

+(ContentManager*)sharedManager;

-(void)tryToLoadFromRemoteFile;
-(void)addIssuesInNewsstandLibrary;

-(NSURL *)contentURLForIssueWithName:(NSString *)name;
-(NSString*)issueDescriptionAtIndex:(NSInteger)index;
-(NSURL*)coverUrlOfIssueAtIndex:(NSInteger)index isRetina:(BOOL)retina;
-(NSString *)nameOfIssueAtIndex:(NSInteger)index;
-(NSString *)titleOfIssueAtIndex:(NSInteger)index;

-(void)removeIssueAtIndex:(int)index;
-(void)removeAllIssues;

//slides and actions
-(NSString*)slideImageLinkAtIndex:(NSInteger)index isRetina:(BOOL)retina isPortraitOrientation:(BOOL)portrait;
-(NSDictionary*)slideActionAtIndex:(NSInteger)index;
-(NSString*)slideActionIdentifierFromSlideActionAtIndex:(NSInteger)index;
-(NSString*)slideActionParameterFromSlideActionAtIndex:(NSInteger)index;

//return free subscription product identifier from slider
-(NSString*)freeSubscriptionProductIdFromSlides;

@end
