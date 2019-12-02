# ISO8583
ISO-8583 Parser in Perl (pack and unpack)
### comments
I have tested afew free pack and unpack madule. the best was open source npm madule (https://www.npmjs.com/package/iso-8583) and an online parser which was available (http://www.licklider.cl/services/financial/iso8583parser/) but still non of them conform, they may have impelimented different version of standard or their implimentation may be wrong. Any way with this library you can easily select any implimentation detail for any of the iso fields.
## Implimentation Details
we have three type of data binary,numeric,alpha-numeric(ASCII)
### Binary: string of hexadesimal characters (0123456789ABCDEF)
### Numeric: string of decimal characters (0123456789)
### AlphaNumeric: String of any ASCII charachter such as (a..z A..z 0..9 !@#$%^&* )
#### Packing Fixed length Data
we will pack binary data as is (so no transformation will applay on binary data). numeric data will be transformed to packed-BCD format ( so for example 12 will be stored as one byte hexadesimal or 123 will be left padded with zero and stored as two byte hexadesimal 0123). AlphaNumeric characters will first represented by their ASCII code in hex, and resulted hex string will be stored ( so for example xMz12 will be tansformed to 784D7A3132 and stored in 5 bytes)
#### Packing Variable length Data
for variable length data we should add the length of data at the begining of it. the data length itself can be formatted in binary, packed-BCD or ASCII, but which format we should use? (you may know ISO8583 dose not have any varible length binary data)
##### iso 8583 from wikipedia
LL can be one or two bytes. For example, if compressed as one hex byte, '27x means there are 27 VAR bytes to follow. If ASCII, the two bytes '32x, '37x mean there are 27 bytes to follow. Three-digit field length LLL uses two bytes with a leading '0' nibble if compressed, or three bytes if ASCII. The format of a VAR data element depends on the data element type. If numeric it will be compressed, e.g. 87456 will be represented by three hex bytes '087456x. If ASCII then one byte for each digit or character is used, e.g. '38x, '37x, '34x, '35x, '36x. 
##### what about len format?
It dose not say if len format for variable len numeric data should be packed-BCD or ASCII, the same goes for AlphaNumeric data it does not say if len format for variable len alpha-numeric data should be packed-BCD or ASCII, for sure packed-BCD format is more size efficient, but it also make sense if we assume the len format should match the data format. (the free implimentation I have checked does not match in this regard.) Anyway I have implimented the packager so you can select the len format yourself
## some examples
In this section I will present some example from various data types and compare with two free implimentations mentioned above
### fixed len binary data
I will use iso field 52 (52 	b 64 	Personal identification number data ) as an example, assume the PIN=0123456789ABCDEF, assume we have function pack which pack the input data according to its format
```bash
pack(b,64,0123456789ABCDEF) = 0123456789ABCDEF ;

```
```perl
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BIN','BIN','FIX',64)->Pack("0123456789ABCDEF");
print $out,"\n";
```
```js
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[52, "0123456789ABCDEF"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
it does not works as expected
### fixed len numeric data
I will use iso field 4 (4 	n 12 	Amount, transaction ) as an example, assume the Amount=1000, assume we have function pack which pack the input data according to its format
```bash
pack(n,12,1000) = 000000001000 ;

```
```perl
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','BCD','FIX',12)->Pack("1000");
print $out,"\n";
```
```js
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
pack(b,64,abcd1234wxyz) = 61626364313233347778797A ;

```
```perl
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('ASC','ASC','FIX',12)->Pack("abcd1234wxyz");
print $out,"\n";
```
```js
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
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','BCD','VAR',19)->Pack("1234567812345678");
print $out,"\n";
```
```js
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
use DataPackager::LV;
my $f = new DataPackager::LV();
my $out = $f->Set('BCD','ASC','VAR',28)->Pack("1234567812345678=95");
print $out,"\n";
```
```js
var ISO8583 = require('iso-8583');
var p = new ISO8583.Message();
var msg = [
	[34, "1234567812345678=95"],
];
var out = p.packSync(msg);
console.log(out.join(''));

```
as you can see in this example although the variable type is alpha numeric the len type is packe BCD, but the iso8583parser from licklider.cl cannot parse it correctly, even if we change the len type to ASCII !
