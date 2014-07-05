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
@property (nonatomic, strong) UIActivityIndicatorView * connectivityIndicator;
@end

@implementation VLCSubtitleManagerTableViewController
- (instancetype)initWithMediaPlayer:(VLCMediaPlayer *) mediaPlayer withFileName:(NSString *) filename
{
    self = [super init];
    if (self) {
        self.mediaPlayer = mediaPlayer;
        self.fileName = filename;
        self.tableView.backgroundColor = [UIColor colorWithRed:(43.0f/255.0f) green:(43.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0f];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        self.connectivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.connectivityIndicator.frame = CGRectMake(self.tableView.center.x, self.tableView.center.y, 24, 24);
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * barButtomItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
    
     self.navigationItem.rightBarButtonItem = barButtomItem;
  
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseCellEmbebedCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseCellExternalSubtitlesCell];
  
    
    [self getAllSubtitles];
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
    [[OSubManager sharedObject] searchSubtitlesForString:self.fileName onQuery:^(BOOL hasResults, NSArray * results)
    {
        if (hasResults) {
            self.subtitles = results;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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
    return [self.mediaPlayer videoSubTitlesNames];
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSObject *headerText;
    switch(section) {
        case VLCSubtitleManagerEmbebedCells:
            headerText =  NSLocalizedString(@"EMBEBED_SUBTITLES", nil);
            break;
        case VLCSubtitleManagerExternalCells:
            headerText =  NSLocalizedString(@"OPENSUBTITLES_SUBTITLES", nil);
            break;
    }
    
    UIView *headerView = nil;
    if (headerText != [NSNull null]) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
        if (!SYSTEM_RUNS_IOS7_OR_LATER) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = headerView.bounds;
            gradient.colors = @[
                                (id)[UIColor colorWithRed:(66.0f/255.0f) green:(66.0f/255.0f) blue:(66.0f/255.0f) alpha:1.0f].CGColor,
                                (id)[UIColor colorWithRed:(56.0f/255.0f) green:(56.0f/255.0f) blue:(56.0f/255.0f) alpha:1.0f].CGColor,
                                ];
            [headerView.layer insertSublayer:gradient atIndex:0];
        } else
            headerView.backgroundColor = [UIColor VLCDarkBackgroundColor];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
        textLabel.text = (NSString *) headerText;
        textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 0.8f)];
        textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        textLabel.shadowColor = [UIColor VLCDarkTextShadowColor];
        textLabel.textColor = [UIColor colorWithRed:(118.0f/255.0f) green:(118.0f/255.0f) blue:(118.0f/255.0f) alpha:1.0f];
        textLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:textLabel];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
        topLine.backgroundColor = [UIColor colorWithRed:(95.0f/255.0f) green:(95.0f/255.0f) blue:(95.0f/255.0f) alpha:1.0f];
        [headerView addSubview:topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
        bottomLine.backgroundColor = [UIColor colorWithRed:(16.0f/255.0f) green:(16.0f/255.0f) blue:(16.0f/255.0f) alpha:1.0f];
        [headerView addSubview:bottomLine];
    }
    return headerView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
            if ([self.subtitles count] > 0) {
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
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = self.tableView.backgroundColor;
    switch (indexPath.section) {
        case VLCSubtitleManagerEmbebedCells: {
            if ([self hasEmbebedSubtitles]) {
                cell.textLabel.text = [self embebedSubtitles][indexPath.row];
            } else {
                cell.textLabel.text = NSLocalizedString(@"NO_RESULTS", @"");
            }
        }break;
            
        case VLCSubtitleManagerExternalCells:
            if ([self.subtitles count] != 0) {
                
                Subtitle * subtitle = self.subtitles[indexPath.row];
                cell.textLabel.text = subtitle.SubFileName;
                
            } else {
                cell.textLabel.text = NSLocalizedString(@"NO_RESULTS", @"");
            }
            break;
        default:
            break;
    }

    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case VLCSubtitleManagerEmbebedCells: {
            if ([self hasEmbebedSubtitles]) {
                [self onEmbebedSubtitleSelect: indexPath.row];
            }
        }break;
            
        case VLCSubtitleManagerExternalCells:
            if ([self.subtitles count] != 0) {
                Subtitle * subtitle = self.subtitles[indexPath.row];
                NSString * tempSubtitleLocation = [NSTemporaryDirectory() stringByAppendingPathComponent:subtitle.SubFileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:tempSubtitleLocation]) {
                    [_mediaPlayer openVideoSubTitlesFromFile:tempSubtitleLocation];
                    return;
                }
                
                [[OSubManager sharedObject] downloadSubtitleWithId:subtitle.IDSubtitleFile onDownloadFinish:^(NSData * data) {
                    [data writeToFile:tempSubtitleLocation atomically:YES];
                    [_mediaPlayer openVideoSubTitlesFromFile:tempSubtitleLocation];

                } onFail:^(int code) {
                    //Could not download subtitle
                }];

            }
            break;
        default:
            break;
    }
 
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
