//
// Created by zhangchao on 14/10/31.
// Copyright (c) 2014 zhangchao. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper {

}

+ (NSString *) getDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = paths[0];
    return documentsDir;
}

+ (NSArray *) getFilesListInDirectory:(NSString *)directory {
    return [self getFilesListInDirectory:directory filterSuffix:@".*"];
}

/** @return a NSURL array */
+ (NSArray *) getFilesListInDirectory:(NSString *)directory filterSuffix:(NSString *)suffix {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    for (NSString *path in filePaths) {
        if ([path hasSuffix:suffix] || [suffix isEqualToString:@".*"]) {
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", directory, path]];
            [result addObject:url];
        }
    }
    // sort elements, default is ASC.
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [[(NSURL*)obj1 absoluteString] compare:[(NSURL*)obj2 absoluteString]];
        if (result == NSOrderedAscending) {
            return NSOrderedAscending;
        } else if (result == NSOrderedDescending) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return result;
}

+ (void) removeFile:(NSString *)fileName {
    NSLog(@"removeFile %@", fileName);
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:fileName error:nil];
}

+ (NSString *) getFilesName:(NSString *)path {
    NSMutableArray *fileName = [NSMutableArray arrayWithArray:[[path lastPathComponent] componentsSeparatedByString:@"."]];
    [fileName removeLastObject];
    return [fileName componentsJoinedByString:@"."];
}

+ (unsigned int)getFilesLength:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path options:NSUncachedRead error:nil];
    return data.length;
}

+ (NSString *) getFilesSize:(NSString *)path {
    double length = [self getFilesLength:path] * 1.0;
    NSArray *units = @[@" B", @" KB", @" MB", @" GB", @" TB"];
    unsigned int i = 0;
    for (i = 0; length >= 1024 && i < 4; i++ ) {
        length = length / 1024;
    }
    return [NSString stringWithFormat:@"%.2f %@", length, units[i]];
}

+ (NSString *)generateFilePathFromDate {
    return [self generateFilePathFromDateWithString:@""];
}

+ (NSString *)generateFilePathFromDateWithString:(NSString *)string {
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *locationString = [dateformatter stringFromDate:senddate];

    NSLog(@"locationString:%@, %@", locationString, string);

    NSString *documentsDir = [self getDocumentsDirectory];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@%@.%@", documentsDir, locationString, string, @"gpx"];

    filePath = [self generateNewFilePathIfExist:filePath index:0];

    return filePath;
}

+ (NSString *)generateNewFilePathIfExist:(NSString *)path index:(int) index {
    NSString *directory = [self getDocumentsDirectory];
    NSArray *fileList = [self getFilesListInDirectory:directory];
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    if ([fileList containsObject:fileUrl]) {
        NSMutableArray *fileNames = [NSMutableArray arrayWithArray:[[fileUrl lastPathComponent] componentsSeparatedByString:@"."]];
        int count = [fileNames count];
        if (count == 2) {
            [fileNames removeLastObject];
        } else if (count >= 3) {
            [fileNames removeLastObject];
            [fileNames removeLastObject];
        }
        NSString *fileName = fileNames[0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.%d.%@", directory, fileName, index + 1, @"gpx"];
        NSLog(@"file exist, need create another one. %@", filePath);
        return [self generateNewFilePathIfExist:filePath index:index + 1];
    }
    return path;
}

+ (NSURL *)generateFileUrlFromDate {
    return [self generateFileUrlFromDateWithString:@""];
}

+ (NSURL *)generateFileUrlFromDateWithString:(NSString *)string {
    NSString *filePath = [self generateFilePathFromDateWithString:string];
    NSURL *fileUrl = [self generateNewFileUrlIfExist:[NSURL fileURLWithPath:filePath] index:0];

    return fileUrl;
}

+ (NSURL *)generateNewFileUrlIfExist:(NSURL *)url index:(int) index {
    NSString *filePath = [self generateNewFilePathIfExist:[url relativePath] index:index + 1];
    NSURL *newUrl = [NSURL fileURLWithPath:filePath];
    return newUrl;
}
@end