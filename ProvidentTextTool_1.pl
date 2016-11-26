#!/usr/bin/perl
use warnings;
use ProvidentTextTool;

my $CFG_FILE_NAME  = "ProvidentTextTool.cfg";
my $HTML_FILE_NAME = "ProvidentTextTool.html";

my $daysLateLowerBound   = ReadConfigFile($CFG_FILE_NAME,"dayslate_min");
my $daysLateUpperBound   = ReadConfigFile($CFG_FILE_NAME,"dayslate_max");
my $homeDirectory        = ReadConfigFile($CFG_FILE_NAME,"home_dir");
my $amReport             = ReadConfigFile($CFG_FILE_NAME,"am_report");
my $phoneNumber          = ReadConfigFile($CFG_FILE_NAME,"phone_number");

if (open(HTML_OUTPUT_FILE,'>',$HTML_FILE_NAME) == 0) {
	   print "Error opening: ProvidentTextTool.html";
	   exit -1;  
}
	
main_entry(HTML_OUTPUT_FILE,$homeDirectory,$amReport,$daysLateLowerBound,$daysLateUpperBound,$phoneNumber);




