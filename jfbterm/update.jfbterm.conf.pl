#!/usr/bin/perl
#---------------------------------------------------------------------------------------------------
# Author
# - Lee Jong Wook(koowgnojeel@daum.net)
# - March 1st, 2010 - http://en.wikipedia.org/wiki/March_1st_Movement
# - Copyleft
#
# Descriptions
# - Update jfbterm && uim settings to read and write Korean Language(ko_KR.UTF-8) within VT.
#
# - You need to install "jfbterm" / "uim-hangul" / "uim" first.
#
# - To test
# 1. < Go to Virtual Terminal >
# 2. $ jfbterm;
# 3. $ jfbterm -c="utf-8" -r;
# 4. $ uim-fep -u hangul2;
# 5. < Press "Ctrl" and "Spacebar" then type Korean >
# 6. < Press "Ctrl" and "Spacebar" again to go back to English mode >
# 7. < Open text-based web browser and goto http://en.wikipedia.org/wiki/korean_language >
#
# - To use EUC-KR, you need to edit "/etc/jfbterm.conf" file.
# 1. Find "encoding.UTF-8 : other,UTF-8,iconv,EUC-KR"
# 2. Replace it to "encoding.UTF-8 : UTF-8,iso10646.1"
#---------------------------------------------------------------------------------------------------
 
use strict;
use warnings;
 
my $const_fname_jfbterm = "/etc/jfbterm.conf";
my $const_fname_uim = "/usr/share/uim/generic-key-custom.scm";
 
my $const_regex_jfbterm = "encoding.UTF-8 : UTF-8,iso10646.1"; # EUC-KR
my $const_replacement_jfbterm = "encoding.UTF-8 : other,UTF-8,iconv,EUC-KR"; # UTF-8
 
my $const_regex1_uim = q!\(define-custom 'generic-on-key '\("zenkaku-hankaku" "<Shift> "\)!;
my $const_replacement1_uim = q!(define-custom 'generic-on-key '("zenkaku-hankaku" "<Control> ")!;
 
my $const_regex2_uim = q!\(define-custom 'generic-off-key '\("zenkaku-hankaku" "<Shift> "\)!;
my $const_replacement2_uim = q!(define-custom 'generic-off-key '("zenkaku-hankaku" "<Control> ")!;
 
my %ansicolor = (
"black" => "\033[0;30m",
"red" => "\033[0;31m",
"green" => "\033[0;32m",
"yellow"=> "\033[0;33m",
"blue" => "\033[0;34m",
"purple"=> "\033[0;35m",
"cyan" => "\033[0;36m",
"white" => "\033[0;37m",
"normal"=> "\033[0m"
);
 
sub isRoot{
my $uid = undef;
my $returnValue = undef;
 
(undef, undef, $uid, undef, undef, undef, undef, undef, undef, undef) = getpwnam(getpwuid($<));
$returnValue = ($uid == "0") ? "1" : "0";
return($returnValue);
}
 
sub readContents($){
my $filename = ${($_[0])};
my $filehandle = undef;
my @contents = "";
 
if( !open($filehandle, "<", $filename) ){
print($ansicolor{yellow}."\nCouldn't open \"$filename\"\n".$ansicolor{normal});
}else{
@contents = <$filehandle>;
close($filehandle);
}
return(@contents);
}
 
sub writeContents($@){
my $filename = ${($_[0])};
my @contents = @{($_[1])};
 
my $filehandle = undef;
my $cnt = undef;
 
open($filehandle, ">", $filename);
foreach $cnt (@contents){
print($filehandle $cnt);
}
close($filehandle);
print($ansicolor{normal}."\nlog::$filename saved\n".$ansicolor{normal});
}
 
sub findString(@$){
my @contents = @{($_[0])};
my $targetString= ${($_[1])};
 
my $cnt = undef;
my $returnValue = 0;
 
foreach $cnt (@contents){
if( $cnt =~ m/$targetString/ ){
$returnValue = 1;
last;
}
}
return($returnValue);
}
 
sub replaceString(@$$){
my @contents = @{($_[0])};
my $regex = ${($_[1])};
my $replacement = ${($_[2])};
 
my $cnt = undef;
my $lineNumber = 0;
 
foreach $cnt (@contents){
$lineNumber += 1;
if( $cnt =~ m/$regex/ ){
print("\nlog::update line".sprintf(" %d",$lineNumber)."\n");
print("log::was$cnt");
print("log::now$replacement");
$cnt =~ s/$regex/$replacement/;
}
}
return(@contents);
}
 
sub debug_print(@){
my @contents = @{($_[0])};
 
my $cnt = undef;
 
foreach $cnt (@contents){
print($cnt);
}
}
 
sub updateContents{
my $filename = ${($_[0])};
my $regex = ${($_[1])};
my $replacement = ${($_[2])};
 
my @contents = undef;
@contents = readContents(\$filename);
if( !$contents[0] eq "" ){
if( findString(\@contents, \$regex) == 1 ){
print($ansicolor{normal}."\nlog::read $filename".$ansicolor{normal});
@contents = replaceString(\@contents, \$regex, \$replacement);
writeContents(\$filename, \@contents);
}
}
}
 
if( isRoot == 1 ){
updateContents(\$const_fname_jfbterm, \$const_regex_jfbterm, \$const_replacement_jfbterm);
updateContents(\$const_fname_uim, \$const_regex1_uim, \$const_replacement1_uim);
updateContents(\$const_fname_uim, \$const_regex2_uim, \$const_replacement2_uim);
}else{
print($ansicolor{yellow}."\nInsufficient privileges - try with sudo command\n".$ansicolor{normal});
}


