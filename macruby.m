#import <MacRuby/MacRuby.h>
#pragma clang diagnostic ignored "-Wobjc-method-access"

@interface RubyRunner:NSObject {

}

- (id) runRubyCode: (NSString *) code method: (NSString *) selector;

- (id) runRubyCodeModuleFromFile: (NSString *) path
                      moduleName: (NSString *) moduleName
                       andMethod: (NSString *) selector;

- (id) runRubyCodeInstanceFromFile: (NSString *) path
                         className: (NSString *) className
                         andMethod: (NSString *) selector;

- (id) runRubyCodeInstanceFromFile:  (NSString *) path
                          className: (NSString *) className
                          andMethod: (NSString *) selector
                      withArguments: (id) args, ...;

- (id) runRubyCodeInstanceFromFile: (NSString *) path
                          className: (NSString *) className
                    constructorArgs: (id) constructorArgs
                          andMethod: (NSString *) selector
                      withArguments: (id) args, ...;

@end

@implementation RubyRunner

- (id) runRubyCode: (NSString *) code method: (NSString *) selector {
  SEL action  = NSSelectorFromString(selector);
  id rubyCode = [[MacRuby sharedRuntime] evaluateString: code];
  return [rubyCode performSelector: action];
}

- (id) runRubyCodeModuleFromFile: (NSString *) path
                      moduleName: (NSString *) moduleName
                       andMethod: (NSString *) selector {
  [self evaluateFile: path];
  SEL action = NSSelectorFromString(selector);
  id module           = [self getRubyClassOrModuleFromName: moduleName];
  id methodEvulation  = [module performRubySelector: action];
  return methodEvulation;
}

- (id) runRubyCodeInstanceFromFile: (NSString *) path
                         className: (NSString *) className
                         andMethod: (NSString *) selector {

  [self evaluateFile: path];
  SEL action  = NSSelectorFromString(selector);
  id class    = [self getRubyClassOrModuleFromName: className];
  id instance = [class performRubySelector:@selector(new)];
  return [instance performSelector:action];
}

- (id) runRubyCodeInstanceFromFile: (NSString *) path
                          className: (NSString *) className
                          andMethod: (NSString *) selector
                      withArguments: (id) args, ... {

  [self evaluateFile: path];
  SEL action  = NSSelectorFromString(selector);
  id class    = [self getRubyClassOrModuleFromName: className];
  id instance = [class performRubySelector:@selector(new)];
  return [instance performRubySelector:action withArguments: args, NULL];
}

- (id) runRubyCodeInstanceFromFile: (NSString *) path
                          className: (NSString *) className
                    constructorArgs: (id) constructorArgs
                          andMethod: (NSString *) selector
                      withArguments: (id) args, ... {

  [self evaluateFile: path];
  SEL action  = NSSelectorFromString(selector);
  id class    = [self getRubyClassOrModuleFromName: className];
  id instance = [class performRubySelector:@selector(new)
                             withArguments: constructorArgs,NULL];
  return [instance performRubySelector:action withArguments: args, NULL];
}

#pragma mark private methods

- (void) evaluateFile: (NSString *) path {
  [[MacRuby sharedRuntime] evaluateFileAtPath:path];
}

- (id) getRubyClassOrModuleFromName: (NSString *) name {
  return [[MacRuby sharedRuntime] evaluateString:name];
}

@end

@interface RubyAssert:NSObject {

}

+ (void) assertString: (id) result withExpection: (NSString *) expection;
+ (void) assertNumber: (id) result withExpection: (NSNumber *) expection;

@end

@implementation RubyAssert

+ (void) assertString: (id) result withExpection: (NSString *) expection {
  BOOL resultCheck = [expection isEqualToString: result];
  [self doAssert: resultCheck withResult: result andExpectedValue: expection];
}

+ (void) assertNumber: (id) result withExpection: (NSNumber *) expection {
  BOOL resultCheck = [expection isEqualToNumber: result];
  [self doAssert: resultCheck withResult: result andExpectedValue:expection];
}

+ (void) doAssert: (BOOL) check withResult: (id) result
         andExpectedValue: (id) expection{
    @try{
    NSAssert(check == YES,
            @"Result '%@' did not match '%@'", result,expection);
    NSString *scenario = [NSString stringWithFormat:
                            @"Result '%@' match '%@'", result,expection];
    NSLog(@"\e[0;32mPassed!\e[m: %@", scenario);
  }
  @catch(NSException *exception){
    NSLog(@"\e[1;31mFailed!\e[m: %@", [exception reason]);
  }
}

@end

@interface ObjectiveCToRubyObject : NSObject

- (void) callWithName: (NSString *) name;
- (NSString *) append: (NSString *) secondString to: (NSString *) firstString;

@end

@implementation ObjectiveCToRubyObject

- (void) callWithName: (NSString *) name{
  NSLog(@"My Name is %@", name);
}

- (NSString *) append: (NSString *) secondString to: (NSString *) firstString{
  return [firstString stringByAppendingString: secondString];
}

@end


@interface MacRubyIntegrationSamples:NSObject {
  RubyRunner *_runner;
}

- (void) run;

@end

@implementation MacRubyIntegrationSamples

- (id) init{
  self = [super init];
  if(self){
    _runner = [[RubyRunner alloc] init];
  }
  return self;
}

- (void) run{
  [self evaluateRubyFromStringAndReturnString];
  [self evaluateRubyFromFileAndReturnString];
  [self evaluateRubyFromFileWithArguments];
  [self delegateObjCToRuby];
}

- (void) delegateObjCToRuby {
  ObjectiveCToRubyObject *obj = [[ObjectiveCToRubyObject alloc] init];
  NSString *file    =  @"test_file_obj_c_objects.rb";
  id instanceResult = [_runner runRubyCodeInstanceFromFile: file
                                                 className: @"ObjcObject"
                                           constructorArgs: obj
                                                 andMethod: @"append_strings_with_objc"
                                             withArguments: @"lade"];
  [RubyAssert assertString: instanceResult
             withExpection: @"Bundeslade"];
  [obj release];
}

- (void) evaluateRubyFromStringAndReturnString {
  NSString *rubySource = [NSString stringWithFormat:@""
    "module RubySample;"
    " def self.foo;"
    "   'I am fooish';"
    " end;"
    "end;"
    "RubySample"];

  NSString *expectResult1 = @"I am fooish";
  id result = [_runner runRubyCode: rubySource method: @"foo"];
  [RubyAssert assertString: result withExpection: expectResult1];
}

- (void) evaluateRubyFromFileAndReturnString {
  NSString *file      =  @"test_file_ruby_sample_string.rb";
  NSString *expected  = @"I am from a file.";
  id result = [_runner runRubyCodeModuleFromFile: file
                                      moduleName: @"StringModule"
                                       andMethod: @"foo"];


  [RubyAssert assertString: result withExpection: expected];

  id instanceResult = [_runner runRubyCodeInstanceFromFile: file
                                                 className: @"RubyClass"
                                                 andMethod: @"foo"];

  [RubyAssert assertString: instanceResult
             withExpection: @"I am from a file and an instance."];
}

- (void) evaluateRubyFromFileWithArguments {
  NSString *file      =  @"test_file_ruby_sample_string.rb";

  id instanceResult = [_runner runRubyCodeInstanceFromFile: file
                                                className: @"RubyClass"
                                                andMethod: @"with_arguments"
                                                withArguments: @"Hubert"];
  [RubyAssert assertString: instanceResult
             withExpection: @"My name is Hubert."];

  NSNumber * toPow = [NSNumber numberWithInteger: 12];
  id numberInstanceResult = [_runner runRubyCodeInstanceFromFile: file
                                                className: @"RubyNumber"
                                                andMethod: @"pow"
                                                withArguments: toPow];
  [RubyAssert assertNumber: numberInstanceResult
             withExpection: [NSNumber numberWithInteger: 144]];

  id numberInstanceSumResult = [_runner runRubyCodeInstanceFromFile: file
                                                className: @"RubyNumber"
                                                andMethod: @"sum"
                                                withArguments: toPow];
  [RubyAssert assertNumber: numberInstanceSumResult
             withExpection: [NSNumber numberWithInteger: 13]];
}

@end

int main(void){
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  MacRubyIntegrationSamples *samples = [[MacRubyIntegrationSamples alloc] init];
  [samples run];
  [samples release];
  [pool drain];
  return 0;
}
