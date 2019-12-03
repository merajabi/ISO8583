# ISO8583
ISO-8583 Parser in Perl (pack and unpack)
### comments
I have tested afew free pack and unpack madule. the best was open source npm madule (https://www.npmjs.com/package/iso-8583) which apperanly impeliments version 1987 of standard and an online parser which was available (http://www.licklider.cl/services/financial/iso8583parser/) which claim to support all version but their implimentation is wrong. Any way with this library you can easily select any implimentation detail for any of the iso fields.
## Implimentation Details
we have three type of data binary,numeric,alpha-numeric(ASCII)
##### Binary: string of hexadesimal characters (0123456789ABCDEF)
##### Numeric: string of decimal characters (0123456789)
##### AlphaNumeric: String of any ASCII charachter such as (a..z A..z 0..9 !@#$%^&* )
#### Packing Fixed length Data
we will pack binary data as is (so no transformation will applay on binary data). numeric data will be transformed to packed-BCD format ( so for example 12 will be stored as one byte hexadesimal or 123 will be left padded with zero and stored as two byte hexadesimal 0123). AlphaNumeric characters will first represented by their ASCII code in hex, and resulted hex string will be stored ( so for example xMz12 will be tansformed to 784D7A3132 and stored in 5 bytes)
#### Packing Variable length Data
for variable length data we should add the length of data at the begining of it. the data length itself can be formatted in binary, packed-BCD or ASCII, but which format we should use? (you may know ISO8583 dose not have any varible length binary data)
##### iso 8583 from wikipedia
LL can be one or two bytes. For example, if compressed as one hex byte, '27x means there are 27 VAR bytes to follow. If ASCII, the two bytes '32x, '37x mean there are 27 bytes to follow. Three-digit field length LLL uses two bytes with a leading '0' nibble if compressed, or three bytes if ASCII. The format of a VAR data element depends on the data element type. If numeric it will be compressed, e.g. 87456 will be represented by three hex bytes '087456x. If ASCII then one byte for each digit or character is used, e.g. '38x, '37x, '34x, '35x, '36x. 
##### what about len format?
In ISO-8583-v2003 the len format of all variable len data are packed-BCD, 
but ISO-8583-v1987 dose not say if len format for variable len numeric data should be packed-BCD or ASCII, the same goes for AlphaNumeric data it does not say if len format for variable len alpha-numeric data should be packed-BCD or ASCII, for sure packed-BCD format is more size efficient, but it also make sense if we assume the len format should match the data format. (the free implimentation I have checked does not match in this regard.) Anyway I have implimented the packager so you can select the len format yourself
## some examples data
In this section I will present some example from various data types and compare with two free implimentations mentioned above
### fixed len binary data
I will use iso field 52 (52 	b 64 	Personal identification number data ) as an example, assume the PIN=0123456789ABCDEF, assume we have function pack which pack the input data according to its format
```bash
pack(b,64,0123456789ABCDEF) = 0123456789ABCDEF ;

```
```perl
#!/usr/bin/perl -w
use lib "../lib";
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BIN','BIN','FIX',64)->Pack("0123456789ABCDEF");
print $out,"\n";
```
```js
#!/usr/bin/node
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[52, "0123456789ABCDEF"],
];
var out = p.packSync(msg);
console.log(out.join(''));
// it does not works as expected
```

### fixed len numeric data
I will use iso field 4 (4 	n 12 	Amount, transaction ) as an example, assume the Amount=1000, assume we have function pack which pack the input data according to its format
```bash
pack(n,12,1000) = 000000001000 ;

```
```perl
#!/usr/bin/perl -w
use lib "../lib";
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','BCD','FIX',12)->Pack("1000");
print $out,"\n";
```
```js
#!/usr/bin/node
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[4, "1000"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
### fixed len alpha numeric data
I will use iso field 37 (37 	an 12 	Retrieval reference number ) as an example, assume the refId=abcd1234wxyz, assume we have function pack which pack the input data according to its format
```bash
pack(an,12,abcd1234wxyz) = 61626364313233347778797A ;

```
```perl
#!/usr/bin/perl -w
use lib "../lib";
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('ASC','ASC','FIX',12)->Pack("abcd1234wxyz");
print $out,"\n";
```
```js
#!/usr/bin/node
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[37, "abcd1234wxyz"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
### variable len numeric data
I will use iso field 2 (2 	n..19 	Primary account number (PAN) ) as an example, assume the PAN=1234567812345678, assume we have function pack which pack the input data according to its format
```bash
pack(n..,19,1234567812345678) = 161234567812345678 ;

```
```perl
#!/usr/bin/perl -w
use lib "../lib";
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','BCD','VAR',19)->Pack("1234567812345678");
print $out,"\n";
```
```js
#!/usr/bin/node
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[2, "1234567812345678"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
### variable len alpha numeric data
I will use iso field 34 (34 	ns ..28 	Primary account number, extended ) as an example, assume the PANE=1234567812345678=95, assume we have function pack which pack the input data according to its format
```bash
pack(ns..,28,1234567812345678=95) = 19313233343536373831323334353637383D3935 ;

```
```perl
#!/usr/bin/perl -w
use lib "../lib";
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','ASC','VAR',28)->Pack("1234567812345678=95");
print $out,"\n";
```
```js
#!/usr/bin/node
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[34, "1234567812345678=95"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
as you can see in this example although the variable type is alpha numeric the len type is packed BCD, but the iso8583parser from licklider.cl cannot parse it correctly, even if we change the len type to ASCII !
## Sample usage of this library
Now I am going to create some compelete ISO-8583 message as an example, I will create ISO-8583 messages in all 1978, 1993 and 2003 format. If your implementation of ISO-8583 differ from the standard you can still use this library, you should just drive a new class from DataFormat and put it in lib/lib/DataFormat along other standard implimentation, (I will write a tutorial for this later :) )
### Authorization / Balance Inquiry
Suppose we are going to sent a message with MTI=0100 and these fields ( 3=003000, 4=100, 7=1203204821, 11=5860, 14=2108, 42=1234567890), because I have no field over 64 the iso bitmap will be 64 bit binary and field 64 will be used for MAC
### ISO 8583 v 1987 impelimentation 
```perl
#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use Tools;
use Packet;
use Bitmap;

my $f = new DataPackager::LV();  # BIN BCD ASC # FIX VAR

my $p1 = new Packet;
my $p2 = new Packet;

{
	local $@;
	eval {
		{
			my $bitmap = new Bitmap(64);
			my $fields = [ 3, 4, 7, 11, 14, 42, 64];
			$bitmap->SetBits(@$fields);
			print "bitmap: ",$bitmap->GetHexStr(),"\n";

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("0100");				# MTI code
			$p1 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($bitmap->GetHexStr());# BITMAP

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 6)->Pack("003000");				# 3 Processing Code
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 12)->Pack("100");				# 4 Transaction Amount
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 10)->Pack("1203204821");		# 7 Transmission Date & Time
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 6)->Pack("5860");				# 11 Systems Trace Audit Number (STAN)
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("2108");				# 14 Expiration Date
			$p1 .= $f->Set('ASC', 'ASC', 'FIX', 15)->Pack("1234567890");		# 42 Card Acceptor Identification Code

			print "ISO Message without MAC: ", $p1->Data(),"\n";
		}
		{
			my $data = $p1->Data();
			my $mac=`./crypt.pl "MAC" "0123456789ABCDEF" $data 16`;				# assume the MAC Key is = 0123456789ABCDEF
			chomp($mac);

			# ISO8583 messaging has no routing information, so is sometimes used with a TPDU header. 
			#$p2 .= $f->Set('BIN', 'BIN', 'FIX', 40)->Pack("FEDCBA9876");		# TPDU	uncomment this line if your implimentation need TPDU header
																				
			$p2 .= $p1;
			$p2 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($mac);				# 64 or 128 Message Authentication Code (MAC)

			print "ISO Message: ", $p2->Data(), "\n";
		}
	}; if($@){
		print $@,"\n";
		exit;
	}
}

{
	local $@;
	eval {
		my ($out,$len,$str);
		my $bitmap = new Bitmap(64);
		$str = $p2->Data();

		#($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 40)->UnPack($str);		# TPDU	uncomment this line if your implimentation need TPDU header
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# MTI
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# bitmap

		$bitmap->SetHexStr($out);
		my $fields = $bitmap->GetBits();
		print "bitmap fields: ",join(' ',@$fields),"\n";

		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 6)->UnPack($str);		# 3 Processing Code
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 12)->UnPack($str);		# 4 Transaction Amount
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 10)->UnPack($str);		# 7 Transmission Date & Time
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 6)->UnPack($str);		# 11 Systems Trace Audit Number (STAN)
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# 14 Expiration Date
		($out,$len,$str) = $f->Set('ASC', 'ASC', 'FIX', 15)->UnPack($str);		# 42 Card Acceptor Identification Code
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# 64 or 128 Message Authentication Code (MAC)

		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}
```

### ISO 8583 v 2003 impelimentation 
```perl
#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use Tools;
use Packet;
use Bitmap;

my $f = new DataPackager::LV();  # BIN BCD ASC # FIX VAR

my $p1 = new Packet;
my $p2 = new Packet;
my $p3 = new Packet;
{
	local $@;
	eval {
		{
			my $bitmap = new Bitmap(64);
			my $fields = [ 3, 4, 7, 11, 14, 42, 64];
			$bitmap->SetBits(@$fields);
			print "bitmap: ",$bitmap->GetHexStr(),"\n";

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("2100");				# ISO-8583 version number n1, MTI code n3 
			$p1 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($bitmap->GetHexStr());# BITMAP

			$p1 .= $f->Set('BCD', 'ASC', 'FIX', 6)->Pack("003000");				# 3 Processing Code

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("9782");				# 4 "Currency code" n3, "minor unit" n1 # EUR 	978 	2 	Euro
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 12)->Pack("100");				# 4 Transaction Amount n12

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 10)->Pack("1225084821");		# 7 Transmission Date & Time UTC (MMDDhhmmss).
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 12)->Pack("5860");				# 11 Systems Trace Audit Number (STAN)
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("2108");				# 14 Expiration Date
			$p1 .= $f->Set('BCD', 'ASC', 'VAR', 35)->Pack("1234567890");		# 42 Card Acceptor Identification Code or Merchant Identifier or 'MID'

			print "ISO Message without MAC: ", $p1->Data(),"\n";
		}
		{
			my $data = $p1->Data();
			my $mac=`./crypt.pl "MAC" "0123456789ABCDEF" $data 16`;
			chomp($mac);

			# ISO8583 messaging has no routing information, so is sometimes used with a TPDU header. 
			#$p2 .= $f->Set('BIN', 'BIN', 'FIX', 40)->Pack("FEDCBA9876");		# TPDU	uncomment this line if your implimentation need TPDU header
																				
			$p2 .= $p1;
			$p2 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($mac);				# 64 or 128 Message Authentication Code (MAC)
		}
		{
			my $hexlen = sprintf( "%04x",length($p2->Data())/2 );
			$p3 .= $f->Set('BIN', 'BIN', 'FIX', 16)->Pack($hexlen);
			$p3 .= $p2;

			print "ISO Message: ", $p3->Data(), "\n";
		}
	}; if($@){
		print $@,"\n";
		exit;
	}
}

{
	local $@;
	eval {
		my ($out,$len,$str);
		my $bitmap = new Bitmap(64);
		$str = $p3->Data();

		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 16)->UnPack($str);		# TPDU	uncomment this line if your implimentation need TPDU header
		#($out,$len,$str) = $f->Set('BCD', 'BIN', 'FIX', 40)->UnPack($str);		# TPDU	uncomment this line if your implimentation need TPDU header
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# MTI
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# bitmap

		$bitmap->SetHexStr($out);
		my $fields = $bitmap->GetBits();
		print "bitmap fields: ",join(' ',@$fields),"\n";

		($out,$len,$str) = $f->Set('BCD', 'ASC', 'FIX', 6)->UnPack($str);		# 3 Processing Code
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 16)->UnPack($str);		# 4 "Currency code" n3, "minor unit" n1, "Transaction Amount" n12
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 10)->UnPack($str);		# 7 Transmission Date & Time
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 12)->UnPack($str);		# 11 Systems Trace Audit Number (STAN)
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# 14 Expiration Date
		($out,$len,$str) = $f->Set('BCD', 'ASC', 'VAR', 35)->UnPack($str);		# 42 Card Acceptor Identification Code
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# 64 or 128 Message Authentication Code (MAC)

		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}
```
