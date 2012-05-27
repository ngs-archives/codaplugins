//
//  WikiPlugin.m
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/28/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "WikiPlugin.h"
#import <WebKit/WebKit.h>
#import "PreviewWindowController.h"

@interface WikiPlugin ()

@property (strong) NSString *cachedHTML;

@end

@implementation WikiPlugin

NSString *const kStylesheetURLDefaultsKey = @"SelectedStylesheetURL";

NSString *const kInitialHTMLTemplate = @"<html>\
<head>\
<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\">\
</head>\
<body>\
%@\
</body>\
</html>";

@synthesize pluginController = _pluginController
, previewWindowController = _previewWindowController
, stylesheetURL = _stylesheetURL
, bundleURL = _bundleURL
, cachedHTML = _cachedHTML
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:kStylesheetURLDefaultsKey])
      self.stylesheetURL = [defaults URLForKey:kStylesheetURLDefaultsKey];
  }
  return self;
}

- (void)textViewDidFocus:(CodaTextView *)textView {
  [self reloadPreview];
  self.previewWindowController.window.title = self.windowTitle;
}

- (void)textViewWillSave:(CodaTextView *)textView {
}


#pragma mark -

- (void)openPreview:(id)sender {
  [self.previewWindowController showWindow:self];
  [self reloadPreview];
  self.previewWindowController.window.title = self.windowTitle;
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
      self.stylesheetURL = pane.URL;
  }];
}

- (void)didPreviewClose {
}


#pragma mark -

- (PreviewWindowController *)previewWindowController {
  if(nil==_previewWindowController)
    _previewWindowController = [[PreviewWindowController alloc] initWithPlugin:self];
  return _previewWindowController;
}

- (void)setStylesheetURL:(NSURL *)stylesheetURL {
  _stylesheetURL = stylesheetURL;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setURL:stylesheetURL forKey:kStylesheetURLDefaultsKey];
  [defaults synchronize];
  [self reloadStylesheet];
}

- (NSURL *)stylesheetURL {
  return _stylesheetURL && [[NSFileManager defaultManager] fileExistsAtPath:_stylesheetURL.path] ?
  _stylesheetURL : [self.bundleURL URLByAppendingPathComponent:@"Contents/Resources/Default.css"];
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

#pragma mark - Render

- (void)reloadStylesheet {
  [[self.previewWindowController.webView.mainFrame windowObject]
   evaluateWebScript:
   [NSString 
    stringWithFormat:
    @"document.querySelector(\"link[rel='stylesheet']\").setAttribute(\"href\", \"%@\")",
    self.stylesheetURL.absoluteString]];
}

- (void)reloadPreview {
  NSString *html = self.html;
  NSError *error = nil;
  WebFrame *frame = self.previewWindowController.webView.mainFrame;
  WebScriptObject *win = [frame windowObject];
  NSString *innerHTML = [win evaluateWebScript:[NSString stringWithFormat:@"document.body.innerHTML;"]];
  if(!innerHTML||[innerHTML isEqualToString:@""]) {
    NSString *contentHTML = [NSString stringWithFormat:kInitialHTMLTemplate,
                             self.stylesheetURL.absoluteString, html];
    [self.previewWindowController.webView.mainFrame
     loadHTMLString:contentHTML
     baseURL:self.bundleURL];
  } else if(![html isEqualToString:self.cachedHTML]) {
    NSString * jsHTML =
    html ?
    [[NSString alloc] initWithData:
     [NSJSONSerialization dataWithJSONObject:html
                                     options:NSJSONReadingAllowFragments
                                       error:&error] encoding:NSUTF8StringEncoding] : @"";
    if(error) NSLog(@"%@", error);
    [win evaluateWebScript:[NSString stringWithFormat:@"document.body.innerHTML=%@",jsHTML]];
  }
  self.cachedHTML = html;
}

@end
