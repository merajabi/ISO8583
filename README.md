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
for variable length data we should add the length of data at the begining of it. the data length itself can be formatted in binary, packed-BCD or ASCII, but which format we should use? (you may know ISO-8583 v1987 dose not have any varible length binary data)
##### ISO 8583 from wikipedia based on the ISO-8583 v1987 standard.
LL can be one or two bytes. For example, if compressed as one hex byte, '27x means there are 27 VAR bytes to follow. If ASCII, the two bytes '32x, '37x mean there are 27 bytes to follow. Three-digit field length LLL uses two bytes with a leading '0' nibble if compressed, or three bytes if ASCII. The format of a VAR data element depends on the data element type. If numeric it will be compressed, e.g. 87456 will be represented by three hex bytes '087456x. If ASCII then one byte for each digit or character is used, e.g. '38x, '37x, '34x, '35x, '36x. 
##### ISO 8583 jPOS Common Message Format based on the ISO-8583 v2003 standard.
Variable length of up to maximum 'nn' characters or digits. All variable length fields shall in addition contain two (abbreviated as LLVAR), three positions (abbreviated as LLLVAR) or four positions (abbreviated as LLLLVAR) at the beginning of the data element representing the length of the field itself.

For Fixed length or Variable length numeric field represented in BCD format, If the number of BCD digits is odd, a final 'F' is added to the right.
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
Now I am going to create some compelete ISO-8583 message as an example, I will create ISO-8583 messages format. If your implementation of ISO-8583 differ from the standard you can still use this library, you should just drive a new class from DataFormat and put it in lib/lib/DataFormat along other standard implimentation, (I will write a tutorial for this later :) )
### Authorization / Balance Inquiry
Suppose we are going to sent a message with MTI=100 and these fields ( 3=003000, 4=100, 7=1225084821, 11=5860, 14=2108, 42=1234567890), because I have no field over 64 the iso bitmap will be 64 bit binary and field 64 will be used for MAC
### ISO-8583 v1987 impelimentation 
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
		{   # Packing Part
			my $bitmap = new Bitmap(64);
			my $fields = [ 3, 4, 7, 11, 14, 42, 64];
			$bitmap->SetBits(@$fields);
			print "bitmap: ",$bitmap->GetHexStr(),"\n";

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("0100");				# MTI code
			$p1 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($bitmap->GetHexStr());# BITMAP

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 6)->Pack("003000");				# 3 Processing Code
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 12)->Pack("100");				# 4 Transaction Amount
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 10)->Pack("1225084821");		# 7 Transmission Date & Time
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
	eval {	# UnPacking Part
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
shell output

```shell
bitmap: 3224000000400001
DataPackager::LV::Pack in:0100 
DataPackager::LV::Pack out:0100 
DataPackager::LV::Pack in:3224000000400001 
DataPackager::LV::Pack out:3224000000400001 
DataPackager::LV::Pack in:003000 
DataPackager::LV::Pack out:003000 
DataPackager::LV::Pack in:100 
DataPackager::LV::Pack out:000000000100 
DataPackager::LV::Pack in:1225084821 
DataPackager::LV::Pack out:1225084821 
DataPackager::LV::Pack in:5860 
DataPackager::LV::Pack out:005860 
DataPackager::LV::Pack in:2108 
DataPackager::LV::Pack out:2108 
DataPackager::LV::Pack in:1234567890 
DataPackager::LV::Pack out:313233343536373839302020202020 
ISO Message without MAC: 0100322400000040000100300000000000010012250848210058602108313233343536373839302020202020
DataPackager::LV::Pack in:ed797c20a4eecd58 
DataPackager::LV::Pack out:ed797c20a4eecd58 
ISO Message: 0100322400000040000100300000000000010012250848210058602108313233343536373839302020202020ed797c20a4eecd58
DataPackager::LV::UnPack in:0100322400000040000100300000000000010012250848210058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:0100 len:4
DataPackager::LV::UnPack in:322400000040000100300000000000010012250848210058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:3224000000400001 len:16
bitmap fields: 3 4 7 11 14 42 64
DataPackager::LV::UnPack in:00300000000000010012250848210058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:003000 len:6
DataPackager::LV::UnPack in:00000000010012250848210058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:000000000100 len:12
DataPackager::LV::UnPack in:12250848210058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:1225084821 len:10
DataPackager::LV::UnPack in:0058602108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:005860 len:6
DataPackager::LV::UnPack in:2108313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:2108 len:4
DataPackager::LV::UnPack in:313233343536373839302020202020ed797c20a4eecd58 
DataPackager::LV::UnPack out:1234567890      len:15
DataPackager::LV::UnPack in:ed797c20a4eecd58 
DataPackager::LV::UnPack out:ed797c20a4eecd58 len:16
```
### ISO 8583 v2003 impelimentation 
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
		{	# Packing Part
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
			$p3 .= $f->Set('BIN', 'BIN', 'FIX', 16)->Pack($hexlen);				# Message length represented as two bytes in network byte order (BIG ENDIAN)
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
	eval {	# UnPacking Part
		my ($out,$len,$str);
		my $bitmap = new Bitmap(64);
		$str = $p3->Data();

		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 16)->UnPack($str);		# Message length represented as two bytes in network byte order (BIG ENDIAN)
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
shell output

```shell
bitmap: 3224000000400001
DataPackager::LV::Pack in:2100 
DataPackager::LV::Pack out:2100 
DataPackager::LV::Pack in:3224000000400001 
DataPackager::LV::Pack out:3224000000400001 
DataPackager::LV::Pack in:003000 
DataPackager::LV::Pack out:303033303030 
DataPackager::LV::Pack in:9782 
DataPackager::LV::Pack out:9782 
DataPackager::LV::Pack in:100 
DataPackager::LV::Pack out:000000000100 
DataPackager::LV::Pack in:1225084821 
DataPackager::LV::Pack out:1225084821 
DataPackager::LV::Pack in:5860 
DataPackager::LV::Pack out:000000005860 
DataPackager::LV::Pack in:2108 
DataPackager::LV::Pack out:2108 
DataPackager::LV::Pack in:1234567890 
DataPackager::LV::PackLen len:10 
DataPackager::LV::PackLen out:10 
DataPackager::LV::Pack out:1031323334353637383930 
ISO Message without MAC: 210032240000004000013030333030309782000000000100122508482100000000586021081031323334353637383930
DataPackager::LV::Pack in:8c349356f512475f 
DataPackager::LV::Pack out:8c349356f512475f 
DataPackager::LV::Pack in:0038 
DataPackager::LV::Pack out:0038 
ISO Message: 00382100322400000040000130303330303097820000000001001225084821000000005860210810313233343536373839308c349356f512475f
DataPackager::LV::UnPack in:00382100322400000040000130303330303097820000000001001225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:0038 len:4
DataPackager::LV::UnPack in:2100322400000040000130303330303097820000000001001225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:2100 len:4
DataPackager::LV::UnPack in:322400000040000130303330303097820000000001001225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:3224000000400001 len:16
bitmap fields: 3 4 7 11 14 42 64
DataPackager::LV::UnPack in:30303330303097820000000001001225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:003000 len:6
DataPackager::LV::UnPack in:97820000000001001225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:9782000000000100 len:16
DataPackager::LV::UnPack in:1225084821000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:1225084821 len:10
DataPackager::LV::UnPack in:000000005860210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:000000005860 len:12
DataPackager::LV::UnPack in:210810313233343536373839308c349356f512475f 
DataPackager::LV::UnPack out:2108 len:4
DataPackager::LV::UnPack in:10313233343536373839308c349356f512475f 
DataPackager::LV::PackLen out:2 
DataPackager::LV::UnPack out:1234567890 len:10
DataPackager::LV::UnPack in:8c349356f512475f 
DataPackager::LV::UnPack out:8c349356f512475f len:16
```
## Refferences

