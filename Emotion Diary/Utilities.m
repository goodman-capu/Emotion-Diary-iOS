//
//  Utilities.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "Utilities.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import <SafariServices/SafariServices.h>

@implementation Utilities

+ (NSString * _Nullable)MD5:(NSString * _Nullable)string {
    if (!string || string.length == 0) {
        return nil;
    }
    const char* cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [outPutStr appendFormat:@"%02X", digest[i]];// 小写 x 表示输出的是小写 MD5 ，大写 X 表示输出的是大写 MD5
    }
    return outPutStr;
}

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRange range = [email rangeOfString:emailRegex options:NSRegularExpressionSearch];
    return (range.location != NSNotFound);
}

+ (UIViewController *)getCurrentViewController {
    return [Utilities getCurrentViewControllerWhileClass:nil appearsWithTime:0 andCanBeTop:YES];
}

+ (UIViewController * _Nullable)getCurrentViewControllerWhileClass:(Class _Nullable)class appearsWithTime:(int)appearTime andCanBeTop:(BOOL)canBeTop {
    UIViewController *view = ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
    int time = [view isKindOfClass:class];
    while (view.childViewControllers.count > 0 || view.presentedViewController) {
        if (view.childViewControllers.count > 0) {
            for (UIViewController *childView in view.childViewControllers) {
                time += [childView isKindOfClass:class];
            }
            view = [view.childViewControllers lastObject];
        }else {
            view = view.presentedViewController;
            time += [view isKindOfClass:class];
        }
    }
    if (!class || (time == appearTime && (!canBeTop && ![view isKindOfClass:class]))) {
        return view;
    }
    return nil;
}

+ (void)openURL:(NSURL *)url inViewController:(UIViewController *)viewController {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        SFSafariViewController *view = [[SFSafariViewController alloc] initWithURL:url];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:view];
        navi.navigationBarHidden = YES;
        [viewController presentViewController:navi animated:YES completion:nil];
    }else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

+ (UIImage *)resizeImage:(UIImage *)image toMaxWidthAndHeight:(NSInteger)max {
    if (image.size.width < max && image.size.height < max) {
        return image;
    }
    CGSize size;
    if (image.size.width > image.size.height) {
        size = CGSizeMake(max, (NSInteger)(max * image.size.height / image.size.width));
    }else {
        size = CGSizeMake((NSInteger)(max * image.size.width / image.size.height), max);
    }
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizeImage;
}

+ (NSData *)compressImage:(UIImage *)image toSize:(int)size {
    float ratio = 1.0;
    NSData *imageData = UIImageJPEGRepresentation(image, ratio);
    while (imageData.length >= size * 1024 && ratio >= 0.05) {
        ratio *= 0.75;
        imageData = UIImageJPEGRepresentation(image, ratio);
    }
    return imageData;
}

+ (NSString *)getFullPathWithPath:(NSString *)path andName:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], path, name];
}

+ (BOOL)checkAndCreatePath:(NSString *)path {
    NSString *fullPath = [[Utilities getFullPathWithPath:path andName:@"null"] stringByDeletingLastPathComponent];
    BOOL isDirectory;
    if (![FILE_MANAGER fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
        return [FILE_MANAGER createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:nil];
    }else {
        return isDirectory;
    }
}

+ (BOOL)fileExistsAtPath:(NSString *)path withName:(NSString *)name {
    NSString *fullPath = [Utilities getFullPathWithPath:path andName:name];
    return [FILE_MANAGER fileExistsAtPath:fullPath];
}

+ (BOOL)createFile:(NSData *)data atPath:(NSString *)path withName:(NSString *)name {
    NSString *fullPath = [Utilities getFullPathWithPath:path andName:name];
    if ([FILE_MANAGER fileExistsAtPath:fullPath]) {
        return NO;
    }
    return [FILE_MANAGER createFileAtPath:fullPath contents:data attributes:nil];
}

+ (BOOL)deleteFileAtPath:(NSString *)path withName:(NSString *)name {
    NSString *fullPath = [Utilities getFullPathWithPath:path andName:name];
    if (![FILE_MANAGER fileExistsAtPath:fullPath]) {
        return YES;
    }
    return [FILE_MANAGER removeItemAtPath:fullPath error:nil];
}

+ (NSData * _Nullable)getFileAtPath:(NSString *)path withName:(NSString *)name {
    NSString *fullPath = [Utilities getFullPathWithPath:path andName:name];
    return [FILE_MANAGER contentsAtPath:fullPath];
}

@end
