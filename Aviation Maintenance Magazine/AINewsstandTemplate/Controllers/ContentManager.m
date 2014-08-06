//
//  ContentManager.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 10.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ContentManager.h"
#import "Reachability.h"
#import "SDWebImageManager.h"


#define CacheDataDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define  cachedJSONFileName [CacheDataDirectory stringByAppendingPathComponent:@"cachedConfig.plist"]

#define DATE_FORMAT @"dd/MM/yyyy"
@interface ContentManager()

@property (readonly,nonatomic) NSString* JSONFileLink;
@end
@implementation ContentManager

//singleton
+(ContentManager*)sharedManager{
    static ContentManager* __sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[ContentManager alloc] init];
    });
    
    return __sharedManager;
}
-(NSString *)JSONFileLink{
     return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? JSON_IPAD_URL : JSON_IPHONE_RUL;
}


-(void)tryToLoadFromCachedFile{
   // NSString* cachedJSONFileName = [CacheDataDirectory stringByAppendingPathComponent:@"cachedConfig.plist"];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cachedJSONFileName];
    
    if (fileExists)
    {
        NSDictionary *json = [NSDictionary dictionaryWithContentsOfFile:cachedJSONFileName];

        //Set title
        self.magazineTitle = json[@"magazine-title"];
        //
        self.issues = [[NSArray alloc] initWithArray:[self sortedByDateIssuesFrom:json[@"issues"]]];
        self.slides = [[NSArray alloc] initWithArray:json[@"slides"]];
        [self addIssuesInNewsstandLibrary];
        
        if (self.issues && self.slides)
        {
            [self.delegate didLoadContent:YES];
        }
    }else{
        NSLog(@"there isn't json file");
        [self.delegate didLoadContent:NO];
    }
}
-(void)tryToLoadFromRemoteFile{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
   
    //Check networkReachability
    if (networkStatus == NotReachable) {
        //offline
        [self tryToLoadFromCachedFile];
    }

    if(networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN)
    {
        //online
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //background queue. Getting data from web
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.JSONFileLink]];
            if (data!=nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fetchData:data];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self tryToLoadFromCachedFile];
                });
            }
            
        });
    }
}
-(void)fetchData:(NSData*)data
{
    NSError* jsonSerializationError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonSerializationError];
    if (json)
    {

        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        //main queue
        [json writeToFile:cachedJSONFileName atomically:YES];
        NSLog(@"%@",cachedJSONFileName);
        //Change icon
        NSString *iconLink = json[@"icon"];
        if (iconLink.length >0) {
            [self updateIcon:json[@"icon"]];
        }
        //Clear all cached images
        BOOL clearImages = [json[@"clearCachedImage"] boolValue];
        NSLog(@"clear cached Images %@", clearImages ? @"YES": @"NO");
        if (clearImages) {
            [[SDImageCache sharedImageCache] clearDisk];
        }
        [self tryToLoadFromCachedFile];

    }

    
}

-(void)updateIcon:(NSString*)iconUrl{
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:iconUrl]
                                               options:SDWebImageCacheMemoryOnly
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
       //downloading icon image
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        
        if (finished) {
            [[UIApplication sharedApplication] setNewsstandIconImage:image];
        }
    }];
}
#pragma mark - issue manager
-(void)addIssuesInNewsstandLibrary{
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    for (NSDictionary *issueDict  in self.issues)
    {
        NSString *name = issueDict[@"name"];
        NKIssue *nkIssue = [nkLib issueWithName:name];
        if (!nkIssue)
        {
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:DATE_FORMAT];
            NSDate *issueDate  = [dateFormatter dateFromString:issueDict[@"date"]];
            nkIssue = [nkLib addIssueWithName:name
                                         date:issueDate ? issueDate : [NSDate date]];
        }
    }
}

-(NSURL*)coverUrlOfIssueAtIndex:(NSInteger)index isRetina:(BOOL)retina{
    NSDictionary* issueInfo = [self.issues objectAtIndex:index];
    NSString *coverPath = nil;
    if (retina) {
        coverPath = [issueInfo objectForKey:@"cover_large"];
    }else{
        coverPath = [issueInfo objectForKey:@"cover_small"];
    }
    return [NSURL URLWithString:coverPath];
}

-(NSString*)issueDescriptionAtIndex:(NSInteger)index{
    return  [self.issues[index]objectForKey:@"description"];
}

-(NSURL *)contentURLForIssueWithName:(NSString *)name {
    __block NSURL *contentURL=nil;
    [self.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *aName = [(NSDictionary *)obj objectForKey:@"name"];
        if([aName isEqualToString:name]) {
            contentURL = [NSURL URLWithString:[(NSDictionary *)obj objectForKey:@"link"]];
            *stop=YES;
        }
    }];
    return contentURL;
}


-(NSString *)nameOfIssueAtIndex:(NSInteger)index {
    return [self.issues[index] objectForKey:@"name"];
}
-(NSString *)titleOfIssueAtIndex:(NSInteger)index {
    return [self.issues[index] objectForKey:@"title"];
}


-(void)removeIssueAtIndex:(int)index{
    NKLibrary *lib = [NKLibrary sharedLibrary];
    NKIssue *issue = [lib issueWithName:[self nameOfIssueAtIndex:index]];
    [lib removeIssue:issue];
}

-(void)removeAllIssues{
    NSLog(@"remove all issues");
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    [nkLib.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [nkLib removeIssue:(NKIssue *)obj];
    }];
    [self addIssuesInNewsstandLibrary];
}
#pragma mark - Slides
-(NSString*)slideImageLinkAtIndex:(NSInteger)index isRetina:(BOOL)retina isPortraitOrientation:(BOOL)portrait{
    NSString *link=@"";
    if (retina && portrait) {
        link = [self.slides[index] objectForKey:@"image@2x_portrait"];
    }
    if (!retina && portrait) {
        link = [self.slides[index]objectForKey:@"image_portrait"];
    }
    if (retina && !portrait) {
        link = [self.slides[index] objectForKey:@"image@2x_landscape"];
    }
    if (!retina && !portrait) {
        link = [self.slides[index] objectForKey:@"image_landscape"];
    }
    return link;
}
-(NSDictionary*)slideActionAtIndex:(NSInteger)index
{
    return [self.slides[index] objectForKey:@"action"];
}
-(NSString*)slideActionIdentifierFromSlideActionAtIndex:(NSInteger)index{
    return [self slideActionAtIndex:index][@"actionIdentifier"];
}
-(NSString*)slideActionParameterFromSlideActionAtIndex:(NSInteger)index{
    return [self slideActionAtIndex:index][@"actionParameter"];
}

-(NSString*)freeSubscriptionProductIdFromSlides{
    NSString* freeSubscriptionIdentifier =@"";
    for (int i =0; i<self.slides.count; i++) {
        NSString*currentSlideActionIdentifier = [self slideActionIdentifierFromSlideActionAtIndex:i];
        if ([currentSlideActionIdentifier isEqualToString:@"subscribe"]) {
            freeSubscriptionIdentifier = [self slideActionParameterFromSlideActionAtIndex:i];
        }
    }
    return freeSubscriptionIdentifier;
}


#pragma mark - Sort issues by date
-(NSArray*)sortedByDateIssuesFrom:(NSArray*)unsortedIssues{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = DATE_FORMAT;
    NSSortDescriptor *sortDescr = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [df dateFromString:obj1 ];
        NSDate *date2 = [df dateFromString:obj2 ];
        
        return [date1 compare:date2];
    }];
    NSArray * sortedArrayByDate = [unsortedIssues sortedArrayUsingDescriptors:@[sortDescr]];
    return sortedArrayByDate;
}

@end
