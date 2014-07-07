//
//  VLCSubtitleSettingsViewController.m
//  VLC for iOS
//
//  Created by Filipe Teixeira on 05/07/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import "VLCSubtitleSettingsViewController.h"
#import "OpensubtitleAPI.h"
#import "VLCSubtitleLangTableViewCell.h"

#define reuseCell @"settingsReuseCell"

@interface VLCSubtitleSettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray * languagesList;

@property (nonatomic, strong) NSMutableArray * languagesSelected;

@property (nonatomic, strong) UIActivityIndicatorView * connectivityIndicator;
@end

@implementation VLCSubtitleSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:(43.0f/255.0f) green:(43.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[VLCSubtitleLangTableViewCell class] forCellReuseIdentifier:reuseCell];

    self.connectivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    [self isLoading];
    self.languagesSelected = [NSMutableArray new];
    for (NSString * lang in [[NSUserDefaults standardUserDefaults] arrayForKey:kVLCSettingSubtitlesLang]) {
        [self.languagesSelected addObject:lang];
    }
    NSString *preferredLang = [[NSLocale preferredLanguages] firstObject];
    [[OSubManager sharedObject] retrieveCountryLanguagesLocalizedTo:preferredLang onResult:^(BOOL hasResults, NSArray * results) {
        if (hasResults) {
            self.languagesList = results;
            [self.tableView reloadData];
        }
        [self isNotLoadingAnymore];
    }];
}
-(void) isLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.connectivityIndicator.frame = self.tableView.frame;
        
        [self.connectivityIndicator startAnimating];
        
        [self.view addSubview:self.connectivityIndicator];
        
    });
}

-(void) isNotLoadingAnymore {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.connectivityIndicator stopAnimating];
        
        [self.connectivityIndicator removeFromSuperview];
        
    });
    
}

-(void) updateLangList
{
    [[NSUserDefaults standardUserDefaults] setObject:self.languagesSelected forKey:kVLCSettingSubtitlesLang];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark UITableViewDataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.languagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VLCSubtitleLangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCell forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = self.tableView.backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Languages * lang = self.languagesList[indexPath.row];
    
    cell.textLabel.text = lang.LanguageName;
    cell.switchHasChanged = ^(BOOL isSelected) {
        if (isSelected) {
            [self.languagesSelected addObject:lang.SubLanguageID];
            
        } else {
            [self.languagesSelected removeObject:lang.SubLanguageID];
        }
        [self updateLangList];
    };
    
    if ([self.languagesSelected indexOfObject:lang.SubLanguageID] != NSNotFound) {
        cell.langSwitch.on = YES;
    }  else {
        cell.langSwitch.on = NO;
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
@end
