//
//  Categories.m
//  SSAView
//
//  Created by Alexander Strange on 1/18/07.
//  Copyright 2007 Perian Project. All rights reserved.
//

#import "Categories.h"

@implementation NSCharacterSet(STUtilities)
+ (NSCharacterSet *)newlineCharacterSet
{
	const unichar chars[] = {'\r','\n',0x0085,0x2028,0x2029};
	return [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:chars length:5]];
}
@end

@implementation NSScanner (STAdditions)
- (int)scanInt
{
	int r;
	[self scanInt:&r];
	return r;
}
@end

@implementation NSString (STAdditions)
- (NSString *)stringByStandardizingNewlines
{
	NSMutableString *ms = [NSMutableString stringWithString:self];
	[ms replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0,[self length])];
	[ms replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0,[ms length])];
	return ms;
}

- (NSArray *)pairSeparatedByString:(NSString *)str
{
	NSMutableArray *ar = [NSMutableArray arrayWithCapacity:2];
	NSRange r = [self rangeOfString:str options:NSLiteralSearch];
	if (r.length == 0) [ar addObject:self];
	else {
		[ar addObject:[self substringToIndex:r.location]];
		[ar addObject:[self substringFromIndex:r.location + r.length]];
	}
	return ar;
}

- (NSArray *)componentsSeparatedByString:(NSString *)str count:(int)count
{
	NSMutableArray *ar = [NSMutableArray arrayWithCapacity:count];
	NSScanner *sc = [NSScanner scannerWithString:self];
	NSString *scv;
	[sc setCharactersToBeSkipped:nil];
	[sc setCaseSensitive:TRUE];
	
	while (count != 1) {
		count--;
		[sc scanUpToString:str intoString:&scv];
		[sc scanString:str intoString:nil];
		if (scv) [ar addObject:scv]; else [ar addObject:[NSString string]];
		if ([sc isAtEnd]) break;
		scv = nil;
	}
	
	[sc scanUpToString:@"" intoString:&scv];
	if (scv) [ar addObject:scv]; else [ar addObject:[NSString string]];

	return ar;
}

+ (NSString *)stringFromUnknownEncodingFile:(NSString *)file
{
	NSData *data = [NSData dataWithContentsOfMappedFile:file];
	NSStringEncoding encodings[] = {NSUTF8StringEncoding, NSUnicodeStringEncoding, NSWindowsCP1252StringEncoding, NSWindowsCP1251StringEncoding};
	NSString *str = nil;
	int i;
	
	for (i = 0; i < sizeof(encodings) / sizeof(NSStringEncoding); i++) {
		str = [[NSString alloc] initWithData:data encoding:encodings[i]];
		
		if (str) return [str autorelease];
	}
	
	NSLog(@"Perian: unable to determine character encoding of %@",file);
	return nil;
}
@end
