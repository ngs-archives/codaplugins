//
//  WikiPlugin.m
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/28/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "WikiPlugin.h"
#import "PreviewWindowController.h"

@interface WikiPlugin ()

@end

@implementation WikiPlugin

@synthesize pluginController = _pluginController
, previewWindowController = _previewWindowController
, bundleURL = _bundleURL
;

#pragma mark - Methods should be implmented in subclasses

- (NSString *)name {
  [NSException raise:@"Not implemented" format:nil];
  return nil;
}

- (NSString *)html {
  [NSException raise:@"Not implemented" format:nil];
  return nil;
}

#pragma mark - CodaPlugin Methods

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                  plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle {
  return self = [self initWithPlugInController:aController withBundleURL:plugInBundle.bundleURL];
}

- (id)initWithPlugInController:(CodaPlugInsController *)aController
                        bundle:(NSBundle *)yourBundle {
  return self = [self initWithPlugInController:aController withBundleURL:yourBundle.bundleURL];
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                 withBundleURL:(NSURL *)bundleURL {
  if(self=[self init]) {
    self.bundleURL = bundleURL;
    self.pluginController = aController;
    [NSEvent addLocalMonitorForEventsMatchingMask:NSRightMouseUpMask handler:^NSEvent *(NSEvent *event) {
      [self reloadPreview];
      return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseUpMask handler:^NSEvent *(NSEvent *event) {
      [self reloadPreview];
      return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSOtherMouseUpMask handler:^NSEvent *(NSEvent *event) {
      [self reloadPreview];
      return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyUpMask handler:^NSEvent *(NSEvent *event) {
      [self reloadPreview];
      return event;
    }];
    [aController registerActionWithTitle:NSLocalizedString(@"Open preview", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(openPreview:)
                       representedObject:nil
                           keyEquivalent:nil
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Generate HTML", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(generateHTML:)
                       representedObject:nil
                           keyEquivalent:nil
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Select StyleSheet", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(selectStylesheet:)
                       representedObject:nil
                           keyEquivalent:nil
                              pluginName:self.name];
  }
  return self;
}

- (void)textViewDidFocus:(CodaTextView *)textView {
  [self reloadPreview];
}

- (void)textViewWillSave:(CodaTextView *)textView {
}


#pragma mark -

- (void)openPreview:(id)sender {
  [self.previewWindowController showWindow:self];
  [self reloadPreview];
}

- (void)generateHTML:(id)sender {
  NSString *html = self.html;
  CodaTextView *tv = [self.pluginController makeUntitledDocument];
  [tv insertText:html];
}

- (void)selectStylesheet:(id)sender {
  NSOpenPanel *pane = [NSOpenPanel openPanel];
  [pane setAllowedFileTypes:[NSArray arrayWithObject:@"css"]];
  [pane beginWithCompletionHandler:^(NSInteger result) {
    if(result == NSOKButton && pane.URL)
      self.previewWindowController.stylesheetURL = pane.URL;
  }];
}

- (void)reloadPreview {
  self.previewWindowController.window.title = self.windowTitle;
  self.previewWindowController.html = self.html;
}

#pragma mark - Accessors

- (PreviewWindowController *)previewWindowController {
  if(nil==_previewWindowController)
    _previewWindowController = [[PreviewWindowController alloc] initWithPlugin:self];
  return _previewWindowController;
}

- (NSString *)windowTitle {
  CodaTextView *tv = [self.pluginController focusedTextView:self];
  NSString *title = [self.name stringByAppendingString:@" Preview"];
  if(tv.path) {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:tv.path];
    title = [title stringByAppendingFormat:@": %@", [URL lastPathComponent]];
  }
  return title;
}

- (NSURL *)defaultStylesheetURL {
  return [self.bundleURL URLByAppendingPathComponent:@"Contents/Resources/Default.css"];
}

@end
