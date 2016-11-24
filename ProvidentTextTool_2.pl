#!/usr/bin/perl
#use strict;
use warnings;
use Data::Dumper;
use CGI;
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/ProvidentTextTool';
use ProvidentTextTool;	

my $q = CGI->new;
print $q->header;
my %data;

$data{sb} = $q->param('sb');
$data{min} = $q->param('min');
$data{max} = $q->param('max');
$data{home_directory} = $q->param('home_directory');
$data{am_report}      = $q->param('am_report');
$data{num_accounts}   = $q->param('num_accounts');
$data{phone_number}   = $q->param('phone_number');

my $amReport = $data{am_report};
my $homeDirectory = $data{home_directory};
my $providentPhoneNumber = $data{phone_number};

my $sb = $data{sb};

if ($sb eq "Reload Accounts")
{
	my $daysLateLowerBound = $data{min};
	my $daysLateUpperBound = $data{max};
	my $fileHandle = STDOUT;

	main_entry($fileHandle,$homeDirectory,$amReport,$daysLateLowerBound,$daysLateUpperBound,$providentPhoneNumber);
	exit;
}

my $csv_output_filename = sprintf("%s\\ProvidentTextTool_output.csv",$homeDirectory);;

if (open(CSV_OUTPUT_FILE,'>',$csv_output_filename) == 0) {
   print "\nError opening: ProvidentTextTool_output.csv\n";
   exit -1;  
}

print "<html>\n<body>\n";
print "<title>","Provident Texting Utility","</title>\n";
print "<div style=\"display:block;text-align:left\">\n";
print "<a href=\"http://localhost/ProvidentTextTool/ProvidentTextTool.html\" imageanchor=1>\n";
print "<img align=\"left\" src=\"ProvidentTextTool.png\" border=0></a><h1><I>Provident Financial Texting Utility</I></h1><br>\n";

print "<head><style>\n";
print "table { width:50%;}\n";
print "th, td { padding: 10px;}\n";
print "table#table01 tr:nth-child(even) { background-color: #eee; }\n";
print "table#table01 tr:nth-child(odd) { background-color:#fff; }\n";
print "table#table01 th { background-color: #084B8A; color: white; }\n";
print "</style></head>\n";
print "<style TYPE=\"text/css\"></style>\n";
print "<table border=5 id=\"table01\" >\n";
print "<tr><th>Index</th><th>Language</th><th>Days Late</th><th>Customer Name</th><th>Phone Number</th></tr>\n";


print CSV_OUTPUT_FILE "Mobile,Message\n";


$data{num_accounts}  = $q->param('num_accounts');

my $num_accounts_checked=0;

for (my $i=0; $i <= $data{num_accounts}; $i++) 
{
	my $cust_checked  = sprintf("cust_%d_cb", $i);	
	$data{cust_cb} = $q->param($cust_checked);
	
	if ( $data{cust_cb} )
	{
		$num_accounts_checked++;
		
		my $cust_lang = sprintf("cust_%d_lang", $i);	
	    $data{cust_lang} = $q->param($cust_lang);
		
		my $cust_dayslate = sprintf("cust_%d_dayslate", $i);
	    $data{cust_dayslate} = $q->param($cust_dayslate);
		
		my $cust_lastpaymentdate = sprintf("cust_%d_lastpaymentdate", $i);
	    $data{cust_lastpaymentdate} = $q->param($cust_lastpaymentdate);
		
		my $cust_lastname = sprintf("cust_%d_lastname", $i);
	    $data{cust_lastname} = $q->param($cust_lastname);
		
		my $cust_firstname = sprintf("cust_%d_firstname", $i);
	    $data{cust_firstname} = $q->param($cust_firstname);
		
		my $cust_phoneNumberToText = sprintf("cust_%d_phoneNumberToText", $i);
	    $data{cust_phoneNumberToText} = $q->param($cust_phoneNumberToText);

		my $textMessageLanguage = sprintf("%s",$data{cust_lang});
		my $dayslate = sprintf("%s",$data{cust_dayslate});
		my $lastpaymentdate = sprintf("%s",$data{cust_lastpaymentdate});
		my $firstname = sprintf("%s",lc($data{cust_firstname}));
		my $lastname  = sprintf("%s",lc($data{cust_lastname}));
		my $phoneNumberToText = sprintf("%s",$data{cust_phoneNumberToText});
		
		print   "<td align=\"center\">",$num_accounts_checked,"</td>\n";
		print   "<td width=\"4%\" align=\"center\" bgcolor=\"#F3F781\">",uc($textMessageLanguage),"</td>\n";
		print   "<td align=\"center\">",$dayslate,"</td>\n";
		print   "<td align=\"left\">",uc($firstname)," ",uc($lastname),"</td>\n";
		print   "<td align=\"center\">",$phoneNumberToText,"</td>\n";
		print   "</tr>\n";		
		
		my $engTextMessage1 = sprintf("%s,%s %s - your Provident car loan payment is (%d) past due. Please contact %s", 
			$phoneNumberToText, ucfirst($firstname),ucfirst($lastname),$dayslate,$providentPhoneNumber );
		my $espTextMessage1 = sprintf("%s,%s %s - su pago del auto de Provident es (%d) dias atrasado. Por favor de llamar al %s", 
			$phoneNumberToText, ucfirst($firstname),ucfirst($lastname),$dayslate,$providentPhoneNumber);
			
		my $engTextMessage2;
		my $espTextMessage2;

		if ($dayslate >= 60)
		{
			$engTextMessage2 = sprintf(" immediately about payment!  Last payment received: %s\n",$lastpaymentdate);
			$espTextMessage2 = sprintf(" hoy! Su ultimo pago fue recibido: %s\n",$lastpaymentdate);
		}		
		elsif ($dayslate >= 45)
		{
			$engTextMessage2 = sprintf(" today! Last payment received: %s\n", $lastpaymentdate);
			$espTextMessage2 = sprintf(" hoy! Su ultimo pago fue recibido: %s\n",$lastpaymentdate);
		}		
		elsif ($dayslate >= 30)
		{
			$engTextMessage2 = sprintf(" as soon as posssible. Last payment received %s\n", $lastpaymentdate);
			$espTextMessage2 = sprintf(" hoy! Su ultimo pago fue recibido: %s\n",$lastpaymentdate);
		}		
		else
		{
			$engTextMessage2 = sprintf(". Last payment received: %s\n", $lastpaymentdate);
			$espTextMessage2 = sprintf(". Su ultimo pago fue recibido: %s\n",$lastpaymentdate);
		}
		
		if ( $textMessageLanguage eq "english")
		{
			print CSV_OUTPUT_FILE $engTextMessage1.$engTextMessage2;
		}
		elsif ($textMessageLanguage eq "spanish")
		{
			print CSV_OUTPUT_FILE $espTextMessage1.$espTextMessage2;
		}
		else 
		{
			print CSV_OUTPUT_FILE $engTextMessage1.$engTextMessage2;
			print CSV_OUTPUT_FILE $espTextMessage1.$espTextMessage2;
		}		
	}
}

#print   "<br><br><br><b>Number of Accounts: <input type=\"text\" name=\"num_accounts_checked\" value=\"",$num_accounts_checked,"\" size=4 style=\"border:none\" readonly></b><br>\n";   
print   "<br><br><br><br><b>Output Filename: </b><a href=\"",$csv_output_filename, "\">",$csv_output_filename,"</a><br><br>\n";
print   "</table>\n";

print   "</form>\n";
print   "</body>\n";
print   "</html>\n";
print   "<br><br>\n";

close(CSV_OUTPUT_FILE);



	
	







