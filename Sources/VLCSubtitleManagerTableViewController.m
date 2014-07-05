//
//  VLCSubtitleManagerTableViewController.m
//  VLC for iOS
//
//  Created by Filipe Teixeira on 17/06/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import "VLCSubtitleManagerTableViewController.h"
#import "UINavigationController+Theme.h"
#import "OpensubtitleAPI.h"


#define kReuseCellEmbebedCell @"EmbebedCell"
#define kReuseCellExternalSubtitlesCell @"ExternalCell"

typedef NS_ENUM(NSInteger, VLCSubtitleManagerCells) {
    VLCSubtitleManagerEmbebedCells = 0,
    VLCSubtitleManagerExternalCells,
};

@interface VLCSubtitleManagerTableViewController ()

@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, strong) NSArray * subtitles;

@property (nonatomic, strong) NSString * fileName;
@end

@implementation VLCSubtitleManagerTableViewController
- (instancetype)initWithMediaPlayer:(VLCMediaPlayer *) mediaPlayer withFileName:(NSString *) filename
{
    self = [super init];
    if (self) {
        self.mediaPlayer = mediaPlayer;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * barButtomItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
    
     self.navigationItem.rightBarButtonItem = barButtomItem;
}

-(void) dismissView:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController loadTheme];
}

#pragma mark - External Subtitles
-(void) getAllSubtitles {
    [[OSubManager sharedObject] searchSubtitlesForString:@"Orange Machine" onQuery:^(BOOL hasResults, NSArray * results)
    {
        if (hasResults) {
            self.subtitles = results;
        } else {
            //No subtitle found
        }
    }];
}

-(void) retrieveSubtitleWithSubtitle:(Subtitle *) subtitle {
    [[OSubManager sharedObject] downloadSubtitleWithId:subtitle.IDSubtitleFile onDownloadFinish:^(NSData * data) {
        
    } onFail:^(int code) {
        
    }];

}
#pragma mark - Embebed Subtitles
-(NSArray *) embebedSubtitles
{
    return [self.mediaPlayer videoSubTitlesIndexes];
}

-(BOOL) hasEmbebedSubtitles
{
    if([[self.mediaPlayer videoSubTitlesIndexes] count]) {
        return YES;
    }

    return NO;
}

-(NSString *) embebedSubtitleNameForIndex:(NSInteger ) index
{
    NSArray *spuTracks = [self.mediaPlayer videoSubTitlesNames];
    NSArray *spuTrackIndexes = [self.mediaPlayer videoSubTitlesIndexes];
    
    NSString *indexIndicator = ([spuTrackIndexes[index] intValue] == [self.mediaPlayer currentVideoSubTitleIndex])? @"\u2713": @"";
    NSString *buttonTitle = [NSString stringWithFormat:@"%@ %@", indexIndicator, spuTracks[index]];
    
    return buttonTitle;
}

-(void) onEmbebedSubtitleSelect:(NSInteger) index
{
    NSArray * indexArray = self.mediaPlayer.videoSubTitlesIndexes;
    self.mediaPlayer.currentVideoSubTitleIndex = [indexArray[index] intValue];
}

#pragma mark - Table view delegate

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self hasEmbebedSubtitles]) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case VLCSubtitleManagerEmbebedCells: {
            if ([self hasEmbebedSubtitles]) {
                return [[self embebedSubtitles] count];
            } else {
                return 1;
            }
        }break;
            
        case VLCSubtitleManagerExternalCells:
            if ([self.subtitles count] == 0) {
                return self.subtitles.count;
            } else {
                return 1;
            }
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseCell = kReuseCellExternalSubtitlesCell;
    BOOL embebedSubtitleCell = NO;
    if ([self hasEmbebedSubtitles] && indexPath.section == 0) {
        embebedSubtitleCell = YES;
        reuseCell = kReuseCellEmbebedCell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCell forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
