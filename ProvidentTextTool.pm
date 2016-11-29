#!/usr/bin/perl
#use warnings;

our @EXPORT_OK = qw(main_entry);

my $SCRIPT = "http://localhost/ProvidentTextTool/ProvidentTextTool_2.pl";

sub main_entry
{
	my $fileHandle    = $_[0];
	my $homeDirectory = $_[1];
	my $amReport      = $_[2];
	my $daysLateLowerBound = $_[3];
	my $daysLateUpperBound = $_[4];
	my $phoneNumber        = $_[5];
	
	WriteHtmlTopPage($fileHandle,$SCRIPT,$daysLateLowerBound,$daysLateUpperBound);
	WriteHtmlTableHeader($fileHandle);
	my $numAccounts = WriteHtmlTableRows($fileHandle,$homeDirectory,$amReport,$daysLateLowerBound,$daysLateUpperBound);
	WriteHtmlTableFooter($fileHandle,$homeDirectory,$amReport,$numAccounts,$phoneNumber);	
}

sub main_entry_lite
{
	my $fileHandle = $_[0];	
	WriteHtmlBanner($fileHandle);
}

sub WriteHtmlBanner 
{
	my $fileHandle = $_[0];
	
	print $fileHandle "<html>\n<body>\n";
	print $fileHandle "<title>","Provident Texting Utility","</title>\n";
	print $fileHandle "<div style=\"display:block;text-align:left\">\n";
	print $fileHandle "<a href=\"http://localhost/ProvidentTextTool/ProvidentTextTool.html\" imageanchor=1>\n";
	print $fileHandle "<img align=\"left\" src=\"ProvidentTextTool.png\" border=0></a><h1><I>Provident Financial Texting Utility</I></h1><br>\n";	
}

sub WriteHtmlTopPage 
{
	my $fileHandle = $_[0];
	my $script     = $_[1];
	my $lowerBound = $_[2];
	my $upperBound = $_[3];
	
	#print $fileHandle "<html>\n<body>\n";
	#print $fileHandle "<title>","Provident Texting Utility","</title>\n";
	#print $fileHandle "<div style=\"display:block;text-align:left\">\n";
	#print $fileHandle "<a href=\"http://localhost/ProvidentTextTool/ProvidentTextTool.html\" imageanchor=1>\n";
	#print $fileHandle "<img align=\"left\" src=\"ProvidentTextTool.png\" border=0></a><h1><I>Provident Financial Texting Utility</I></h1><br>\n";
	
	WriteHtmlBanner($fileHandle);
	
	print $fileHandle "<form method=\"GET\" action=\"",$script,"\">\n";
	print $fileHandle "Accounts From: <input type=\"number\" name=\"min\" min=\"1\"  max=\"999\" value=\"",$lowerBound,"\">&nbsp\n";
    print $fileHandle "To:<input type=\"number\" name=\"max\" min=\"1\" max=\"999\" value=\"",$upperBound,"\">&nbsp\n";
	print $fileHandle "Days Late &nbsp &nbsp\n","<input type=\"submit\" name=\"sb\" value=\"Reload Accounts\"><br><br>\n";		
}	

sub WriteHtmlTableHeader
{
	my $fileHandle = $_[0];

	print $fileHandle "<head><style>\n";
	print $fileHandle "table { width:100%;}\n";
	print $fileHandle "th, td { padding: 10px;}\n";
	print $fileHandle "table#table01 tr:nth-child(even) { background-color: #eee; }\n";
	print $fileHandle "table#table01 tr:nth-child(odd) { background-color:#fff; }\n";
	print $fileHandle "table#table01 th { background-color: #084B8A; color: white; }\n";
	print $fileHandle "</style></head>\n";
	print $fileHandle "<style TYPE=\"text/css\"></style>\n";
	
	print $fileHandle "<br><br><table border=5 id=\"table01\" >\n";
	print $fileHandle "<tr><th>Select</th><th>English</th><th>Spanish</th><th>Both</th><th>Days Late</th><th>Last Payment</th><th>Name</th><th>Vehicle</th><th>Phone</th></tr>\n";
}

sub WriteHtmlTableRows
{
	my $fileHandle = $_[0];	
	my $homeDirectory = $_[1];
	my $amReport = $_[2];
	my $daysLateLowerBound = $_[3];
	my $daysLateUpperBound = $_[4];
	my $numAccountsInRange = 0;
	
	my $amOpenAccountsReport = sprintf("%s\\%s",$homeDirectory,$amReport);	
	
	## Open file and  make sure the AutoManger file exists
	if (open(AM_INPUT_FILE,$amOpenAccountsReport) == 0) {
	   print "Error opening AutoManager file: ",$amOpenAccountsReport;
	   exit -1;  
	}
	
	while (<AM_INPUT_FILE>) 
	{
		chomp;
		my ($autoyear,$vin,$totaldue,$dealdate,$homephone,$payoff,$monthlypayment,$automodel,$automake,$dayslate,$lastpaymentdate,$textOk,$lastname,$firstname,$repostatus,$cellphone,$amtfinanced,$adjustbalance,$lastpaymentdate,$workphone) = split(",");
		
		$firstname =~ s/^\s+//;
		
		if ($dayslate >= $daysLateLowerBound && $dayslate <= $daysLateUpperBound )
		{
			$numAccountsInRange++;			
			$phoneNumberToText = $cellphone;
		
			if (length $phoneNumberToText < 10)
			{
				if (length $homephone < 10)
				{
					$phoneNumberToText = "(NO NUMBER)";
				}
				$phoneNumberToText = $homephone;		
			}

			my $mySpanish = "";
			my $myEnglish = "checked";
			
			$result = index((uc($textOk)),"SPANISH");
			
			if ($result ne -1)
			{
				$mySpanish = "checked";
				$myEnglish = "";
			}
			
			
			print $fileHandle  "<tr>\n";	
			print $fileHandle  "<td width=\"4%\" align=\"center\" bgcolor=\"#F3F781\"><input type=\"checkbox\" name=\"cust_",$numAccountsInRange,"_cb\" value=\"yes\" checked></td>\n"; 
			print $fileHandle  "<td width=\"6%\" align=\"center\" bgcolor=\"#04B431\"><input type=\"radio\" name=\"cust_",$numAccountsInRange,"_lang\" value=\"english\" ",$myEnglish,"></td>\n";
			print $fileHandle  "<td width=\"6%\" align=\"center\" bgcolor=\"#04B431\"><input type=\"radio\" name=\"cust_",$numAccountsInRange,"_lang\" value=\"spanish\" ",$mySpanish,"></td>\n";
			print $fileHandle  "<td width=\"6%\" align=\"center\" bgcolor=\"#04B431\"><input type=\"radio\" name=\"cust_",$numAccountsInRange,"_lang\" value=\"both\"></td>\n";
			print $fileHandle  "<td width=\"5%\" align=\"center\">",$dayslate,"</td>\n";
			print $fileHandle  "<td width=\"5%\" align=\"center\">",$lastpaymentdate,"</td>\n";	
			print $fileHandle  "<td width=\"20%\" align=\"left\">",uc($firstname)," ",uc($lastname),"</td>\n";
			print $fileHandle  "<td width=\"20%\" align=\"left\">",$autoyear," ",uc($automake)," ",uc($automodel),"</td>\n";
			print $fileHandle  "<td width=\"15%\" align=\"center\">",$phoneNumberToText,"</td>\n";
			#print $fileHandle  "<td align=\"right\" valign=\"top\"><textarea name=\"name\" id=\"\" cols=\"45\" rows=\"3\">This is a test</textarea></td>\n";
			print $fileHandle  "</tr>\n";
			
			print $fileHandle  "<input type=\"hidden\" name=\"cust_",$numAccountsInRange,"_dayslate\" value=\"",$dayslate,"\">\n";
			print $fileHandle  "<input type=\"hidden\" name=\"cust_",$numAccountsInRange,"_lastpaymentdate\" value=\"",$lastpaymentdate,"\">\n";
			print $fileHandle  "<input type=\"hidden\" name=\"cust_",$numAccountsInRange,"_firstname\" value=\"",$firstname,"\">\n";
			print $fileHandle  "<input type=\"hidden\" name=\"cust_",$numAccountsInRange,"_lastname\" value=\"",$lastname,"\">\n";
			print $fileHandle  "<input type=\"hidden\" name=\"cust_",$numAccountsInRange,"_phoneNumberToText\" value=\"",$phoneNumberToText,"\">\n";
		}
	};
	
	close (AM_INPUT_FILE);
	return $numAccountsInRange;
}

sub WriteHtmlTableFooter
{
	my $fileHandle  = $_[0];	
	my $homeDirectory = $_[1];
	my $amReport    = $_[2];
	my $numAccounts = $_[3];
    my $phoneNumber = $_[4];	
	
	print $fileHandle "<input type=\"hidden\" name=\"home_directory\" value=",$homeDirectory,">\n";
	print $fileHandle "<input type=\"hidden\" name=\"am_report\" value=",$amReport,">\n";
	print $fileHandle "<input type=\"hidden\" name=\"phone_number\" value=",$phoneNumber,">\n";
	print $fileHandle "</table>\n";
	print $fileHandle "<br><br><b>Number of Accounts: <input type=\"text\" name=\"num_accounts\" value=\"",$numAccounts,"\" size=4 style=\"border:none\" readonly></b><br>\n";   
	print $fileHandle "<br><br><input type=\"submit\" name=\"sb\" value=\"Submit Accounts for Texting\" style=\"height:30px; width:200px\"><br><br><br>";
}

sub ReadConfigFile
{
	my $cfgFile     = $_[0];
	my $paramToFind = $_[1];
	
	## Open file and make sure the config file exists
	if (open(CFG_FILE, $cfgFile) == 0) {
	   print "Error opening config file: ",$cfgFile;
	   exit -1;  
	}
	
	my $parameter;
	my $value;
	
	while (<CFG_FILE>) 
	{
		chomp;
		($parameter,$value) = split("=");
		
		if ($paramToFind eq $parameter)
		{
			close (CFG_FILE);
			return $value;
		}
	};
	
	print "ReadConfigFile:Error: ",$paramToFind," not found in ",$cfgFile,"\n";
	close (CFG_FILE);
	
	return "";
}


sub WriteConfigFile
{
	my $cfgFile     = $_[0];
	my $paramToFind = $_[1];
	my $newValue    = $_[2];
	
	my $file = path($cfgFile); 
	my $data = $file->slurp;
	$data =~ s/dayslate_min=30/dayslate_min=35/g;
	$file->spew( $data );
	
	return;
}

	
	