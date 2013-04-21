#import "ViewController.h"
#import "SecKeyHelper.h"
#include "/usr/include/base64.h" // https://github.com/superwills/NibbleAndAHalf/blob/master/NibbleAndAHalf/base64.h

void testSecKey()
{
  // THIS IS A STRING REPRESENTING THE GLOBAL IDENTIFIER FOR MY PUBLIC KEY CERTIFICATE
  // ON THE IOS "KEYCHAIN".
  const UInt8 keychainIdStr[] = "com.example.widgets.publickey" ; // YOU MUST USE A CHAR ARRAY[], YOU
  // MAY NOT USE char* OR UInt8* FOR THE POINTER TYPE. Encryption will fail if you do.
  
  // CREATE MY KEYCHAIN IDENTIFIER.  It has to be a CFDataRef.
  // I include the NULL terminator in the CFDataRef by adding +1 to
  // the strlen of the keychainIdStr (because strlen() doesn't count the NULL TERMINATOR
  // even though it is there).
  CFDataRef CFKEYCHAINID = CFDataCreate( 0, keychainIdStr, sizeof(keychainIdStr) ) ;
  
  // If you want, we can DELETE the item corresponding to the CFKEYCHAINID
  // that we created on the last run.
  //////SecCertificateDeleteFromKeyChain( CFKEYCHAINID ) ; // DELETE OLD KEY
  
  SecKeyRef PUBLICKEY = SecKeyFromKeyChain( CFKEYCHAINID ) ;
  if( PUBLICKEY )  puts( "<< KEY RETRIEVAL FROM KEYCHAIN OK!! >>" ) ;
  else
  {
    puts( "FAILED TO LOAD SECKEY FROM KEYCHAIN!!!!!" ) ;
    puts( "Loading from certificate.cer.." ) ;
    
    // LOAD THE PUBLIC KEY FROM certificate.cer.
    NSString* certPath = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"cer"];
    PUBLICKEY = SecKeyFromPathAndSaveInKeyChain( certPath, CFKEYCHAINID ) ;
    if( !PUBLICKEY )
    {
      puts( "DOUBLE FAIL!!!!!  MAKE SURE YOU HAVE LOADED certificate.cer INTO THE XCODE PROJECT "
      "AND THAT IT IS SET UNDER 'COPY BUNDLE RESOURCES'!!!" ) ;
      return ;
    }
  }
  
  int blockSize = SecKeyGetBlockSize( PUBLICKEY ) ;
  printf( "THE MAX LENGTH OF DATA I CAN ENCRYPT IS %d BYTES\n", blockSize ) ;
  
  uint8_t *binaryData = (uint8_t *)malloc( blockSize ) ;
  for( int i = 0 ; i < blockSize ; i++ )
    binaryData[i] = 'A' + (i % 26 ) ; // loop the alphabet
  binaryData[ blockSize-1 ] = 0 ; // NULL TERMINATED ;)
  printf( "ORIGINAL DATA:\n%s\n", (char*)binaryData ) ;

  uint8_t *encrypted = (uint8_t *)malloc( blockSize ) ;
  size_t encryptedLen ;
  SecCheck( SecKeyEncrypt( PUBLICKEY, kSecPaddingNone, binaryData, blockSize, encrypted, &encryptedLen ), 
    "SecKeyEncrypt" ) ;
  free( binaryData ) ;
  
  printf( "ENCODED %d bytes => %lu bytes\n", blockSize, encryptedLen ) ;
  
  int base64DataLen ;
  char* base64Data = base64( encrypted, encryptedLen, &base64DataLen ) ;
  printf( "B64( ENCRYPTED( <<BINARY DATA>> ) ) as %d base64 ascii chrs:\n%s\n", base64DataLen, base64Data ) ;
  free( encrypted ) ;
  
  
  /// SEND base64Data across the net.


  free( base64Data ) ;
}

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  testSecKey() ;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else return YES;

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}





@end