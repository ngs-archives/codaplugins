//
//  PreviewWindowController.m
//  Coda Wiki Plug-Ins Shared
//
//  Created by Atsushi Nagase on 5/26/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "WikiPreviewWindowController.h"
#import "WikiPlugin.h"
#import <WebKit/WebKit.h>

@interface WikiPreviewWindowController ()

@property (strong) NSString *cachedHTML;

@end

@implementation WikiPreviewWindowController

// ------------------------------------------------------------
//   Constants
// ------------------------------------------------------------

NSString *const kWindowSaveName = @"WikiPreviewWindow";

NSString *const kStylesheetURLDefaultsKey = @"SelectedStylesheetURL";

NSString *const kInitialHTMLTemplate = @"<html>\
<head>\
<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\">\
</head>\
<body>\
%@\
</body>\
</html>";

// ------------------------------------------------------------

@synthesize webView = _webView
, plugin = _plugin
, cachedHTML = _cachedHTML
, html = _html
;

- (id)initWithPlugin:(WikiPlugin *)plugin {
  if (self=[super initWithWindowNibName:@"WikiPreviewWindow" owner:self]) {
    self.plugin = plugin;
  }
  return self;
}

#pragma mark - NSWindowController

- (void)windowDidLoad {
  self.window.level = NSStatusWindowLevel;
  self.window.frameAutosaveName = self.frameSaveName;
  if(self.html) [self reloadPreview];
  [super windowDidLoad];
}

- (void)windowDidMove:(NSNotification *)aNotification {
  [self.window saveFrameUsingName:self.frameSaveName];
}

- (void)showWindow:(id)sender {
  [super showWindow:sender];
}

//- (void)windowWillClose:(NSNotification *)notification {
//}

#pragma mark - 

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener {
  if([[actionInformation valueForKey:WebActionNavigationTypeKey] intValue] == WebNavigationTypeLinkClicked) {
    [[NSWorkspace sharedWorkspace] openURL:request.URL];
    [listener ignore];
  } else {
    [listener use];
  }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener {
  [[NSWorkspace sharedWorkspace] openURL:request.URL];
  [listener ignore];
}

#pragma mark - Accessors

- (NSString *)frameSaveName {
  return [NSStringFromClass(self.plugin.class) stringByAppendingString:kWindowSaveName];
}

- (NSString *)stylesheetLocationKey {
  return [NSStringFromClass(self.plugin.class) stringByAppendingString:kStylesheetURLDefaultsKey];
}

- (void)setStylesheetURL:(NSURL *)stylesheetURL {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setURL:stylesheetURL forKey:self.stylesheetLocationKey];
  [defaults synchronize];
  [self reloadStylesheet];
}

- (NSURL *)stylesheetURL {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSURL *URL = [defaults objectForKey:self.stylesheetLocationKey];
  return URL && [URL isKindOfClass:[NSURL class]] && [[NSFileManager defaultManager] fileExistsAtPath:URL.path] ?
  URL : self.plugin.defaultStylesheetURL;
}

- (NSString *)html {
  return _html;
}

- (void)setHtml:(NSString *)html {
  _html = html;
  [self reloadPreview];
}

#pragma mark - Rendering

- (void)reloadStylesheet {
  [[self.webView.mainFrame windowObject]
   evaluateWebScript:
   [NSString 
    stringWithFormat:
    @"document.querySelector(\"link[rel='stylesheet']\").setAttribute(\"href\", \"%@\")",
    self.stylesheetURL.absoluteString]];
}

- (void)reloadPreview {
  NSError *error = nil;
  WebFrame *frame = self.webView.mainFrame;
  WebScriptObject *win = [frame windowObject];
  NSString *innerHTML = [win evaluateWebScript:[NSString stringWithFormat:@"document.body.innerHTML;"]];
  if(!innerHTML||[innerHTML isEqualToString:@""]) {
    NSString *contentHTML = [NSString stringWithFormat:kInitialHTMLTemplate,
                             self.stylesheetURL.absoluteString, self.html];
    [self.webView.mainFrame
     loadHTMLString:contentHTML
     baseURL:self.plugin.bundleURL];
  } else if(![self.html isEqualToString:self.cachedHTML]) {
    NSString * jsHTML =
    self.html ?
    [[NSString alloc] initWithData:
     [NSJSONSerialization dataWithJSONObject:self.html
                                     options:NSJSONReadingAllowFragments
                                       error:&error] encoding:NSUTF8StringEncoding] : @"";
    if(error) NSLog(@"%@", error);
    [win evaluateWebScript:[NSString stringWithFormat:@"document.body.innerHTML=%@",jsHTML]];
  }
  self.cachedHTML = self.html;
}

@end

