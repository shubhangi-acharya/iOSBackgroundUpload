//
//  ViewController.m
//  iOSBackgroundUpload
//
//  Created by MEGANEXUS on 06/08/14.
//  Copyright (c) 2014 sample. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
- (IBAction)btnUpload_Clicked:(id)sender;
@property (nonatomic, strong) NSMutableURLRequest     *request;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma Button Methods

- (IBAction)btnUpload_Clicked:(id)sender {
    
    NSString *baseURL = @"Webservice URL to upload video";
    
    _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseURL]];
    
    // Set up acceptable types
    [_request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [_request setHTTPMethod:@"POST"];

    
    // Need to put NSdata into file when uploading in background
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"YourVideoName" ofType:@"mp4"];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
   

    
    // Set the request body if appropriate
    if( data ) [_request setHTTPBody:data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"myVideo.dat"];
    
    // Save it into file system
    [data writeToFile:dataPath atomically:YES];
    NSURL *fileURL = [NSURL fileURLWithPath:dataPath];
    
    NSURLSession *backgroundSession = [self backgroundSession];
    
    NSURLSessionUploadTask *uploadTask = [backgroundSession uploadTaskWithRequest:_request fromFile:fileURL];
    [uploadTask resume];
}


- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    // Unique identifier is required for each request
    NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"test.identifier"];
    session = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return session;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // Convert obj to an NSData and thence to JSON
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)dataTask.response;
    NSError *error;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSLog(@"%@", jsonObject);
    NSLog(@"Response:: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"%@", response);
    NSString *jsonErrorCode = [jsonObject valueForKey:@"YOUR ERROR CODE"];
    
    if( !jsonErrorCode  ) {
        // No error so we call the success method
        // Code to handle data
        
    } else {
        // This was an error so call the fail method
        // Code to handle error
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
       // Code to handle error
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
}


@end
