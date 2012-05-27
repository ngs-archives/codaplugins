//
//  WikiPlugin.h
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/28/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodaPlugInsController.h"

@class PreviewWindowController;
@interface WikiPlugin : NSObject<CodaPlugIn>

@property (strong) NSURL *bundleURL;

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                 withBundleURL:(NSURL *)bundleURL;
- (NSString *)html;
- (NSString *)windowTitle;
- (NSURL *)defaultStylesheetURL;
- (void)reloadPreview;

@property (strong) CodaPlugInsController *pluginController;
@property (readonly) PreviewWindowController *previewWindowController;


@end
