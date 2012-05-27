//
//  PreviewWindowController.h
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/26/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WikiPlugin, WebView;
@interface PreviewWindowController : NSWindowController

- (id)initWithPlugin:(WikiPlugin *)plugin;
- (NSString *)frameSaveName;

@property (weak) WikiPlugin *plugin;
@property (weak) IBOutlet WebView *webView;


@end
