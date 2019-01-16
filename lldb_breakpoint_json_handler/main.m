//
//  main.m
//  lldb_breakpoint_json_handler
//
//  Created by liaogang on 2018/12/12.
//  Copyright © 2018年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Foundation/Foundation.h>

void printUseage()
{
    printf(
           "LLDB can save/load breakpoint to/from a json file, using 'breakpoint write/read -f filepath'.\n"
           "But usaualy it can not load the breakpoint correctly.\n"
           "this program can fix the json file.\n"
           "fixllbp [filepath] [module_name] [constant offset]\n"
           "example:\n"
           "fixllbp breakpoint Aweme 0x12345\n"
           );
}

// exec filepath module_name 常数C
int main(int argc, const char * argv[]) {
    
    if (argc == 3) {
        
        NSString *filepath = [NSString stringWithUTF8String:argv[1]];
        
        NSString *moduleName = [NSString stringWithUTF8String: argv[2]];
        
        const char *strC = argv[3];
        
        uint64 C = 0;
        
        if( strC[1] == 'x' ){
            sscanf(strC,"%llx", &C);
        }
        else{
            sscanf(strC,"%llu", &C);
        }
        
        
        NSData *data = [[NSData alloc] initWithContentsOfFile: filepath ];
        
        if (data) {
            
            NSArray *root =  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            data = nil;
            
            NSMutableArray *modify = [NSMutableArray array];
            
            for (NSDictionary *tmp in root) {
                
                NSMutableDictionary *dic = [tmp mutableCopy];
                NSMutableDictionary *Breakpoint = [dic[@"Breakpoint"] mutableCopy];
                
                NSMutableDictionary *BKPTOptions = [Breakpoint[@"BKPTOptions"] mutableCopy];
                NSMutableDictionary *BKPTResolver = [Breakpoint[@"BKPTResolver"] mutableCopy];
                NSMutableDictionary *Options = [BKPTResolver[@"Options"] mutableCopy];
                
                
                //change 1
                NSNumber *addressOffset = Options[@"AddressOffset"];
                unsigned long address = addressOffset.unsignedLongValue;
                address += C;
                addressOffset = [NSNumber numberWithUnsignedLong: address];
                Options[@"AddressOffset"] = addressOffset;
                
                //change 2
                Options[@"ModuleName"] = moduleName;
                
                //change 3, add ConditionText if empty
                BKPTOptions[@"ConditionText"] = @"";
                
                if (argc == 5) {
                    //change 4
                    BKPTOptions[@"AutoContinue"] = [NSNumber numberWithBool:1];
                }
                
                BKPTResolver[@"Options"] = Options;
                Breakpoint[@"BKPTResolver"] = BKPTResolver;
                Breakpoint[@"BKPTOptions"] = BKPTOptions;
                
                dic[@"Breakpoint"] = Breakpoint;
                
                [modify addObject: dic];
            }
            
            
            NSData *data2 = [NSJSONSerialization dataWithJSONObject:modify options:NSJSONWritingPrettyPrinted error:nil];
            filepath = [filepath stringByDeletingPathExtension];
            [data2 writeToFile:filepath atomically:YES];
            
            NSLog(@"%lu bytes writed to %@", (unsigned long)data2.length , filepath );
        }
        else{
            NSLog(@"file not exist: %@", filepath);
        }
        
    }
    else{
        printUseage();
    }
    
    return 0;
}
