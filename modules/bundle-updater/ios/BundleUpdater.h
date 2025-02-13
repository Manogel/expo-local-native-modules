#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface BundleUpdater : NSObject <RCTBridgeModule>

+ (NSURL *)getBundleURL;
- (void)clearBundle;
- (NSString *)getBundlePath;
- (NSString *)getBundleInfo;
- (void)applyBundle:(NSString *)bundlePath
      bundleVersion:(NSString *)bundleVersion
           resolver:(RCTPromiseResolveBlock)resolve
           rejecter:(RCTPromiseRejectBlock)reject;

@end 