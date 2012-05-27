//
//  PreviewWindowController.m
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/26/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "PreviewWindowController.h"
#import "WikiPlugin.h"
#import <WebKit/WebKit.h>

@interface PreviewWindowController ()


@end

@implementation PreviewWindowController

NSString *const kWindowSaveName = @"PreviewWindow";

@synthesize webView = _webView
, plugin = _plugin
;

- (id)initWithPlugin:(WikiPlugin *)plugin {
  if (self=[super initWithWindowNibName:@"PreviewWindow" owner:self]) {
    self.plugin = plugin;
  }
  return self;
}

- (void)windowDidLoad {
  self.window.level = NSStatusWindowLevel;
  self.window.frameAutosaveName = self.frameSaveName;
  [super windowDidLoad];
}

- (void)windowDidMove:(NSNotification *)aNotification {
  [self.window saveFrameUsingName:self.frameSaveName];
}

- (void)showWindow:(id)sender {
  [super showWindow:sender];
}

- (void)windowWillClose:(NSNotification *)notification {
  [self.plugin didPreviewClose];
}

- (NSString *)frameSaveName {
  return [NSStringFromClass(self.plugin.class) stringByAppendingString:kWindowSaveName];
}

@end

