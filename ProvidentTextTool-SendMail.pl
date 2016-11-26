 #!/usr/bin/perl
use warnings;
use Try::Tiny;
use IO::All;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use ProvidentTextTool;

my $HTML_FILE_NAME = "ProvidentTextTool-SendMail.html";
my $CFG_FILE_NAME = "ProvidentTextTool.cfg";
my $email_src     = ReadConfigFile($CFG_FILE_NAME,"email_src");
my $email_src_pw  = ReadConfigFile($CFG_FILE_NAME,"email_src_pw");
my $email_dest    = ReadConfigFile($CFG_FILE_NAME,"email_dest");
my $homeDirectory = ReadConfigFile($CFG_FILE_NAME,"home_dir");
my $textReport    = ReadConfigFile($CFG_FILE_NAME,"text_report");
my $textReportFullPath = sprintf("%s\\%s",$homeDirectory,$textReport);
my $datestring = gmtime();

if (open(HTML_OUTPUT_FILE,'>',$HTML_FILE_NAME) == 0) {
	   print "Error opening: ProvidentTextTool-SendMail.html";
	   exit -1;  
}

main_entry_lite(HTML_OUTPUT_FILE);
print HTML_OUTPUT_FILE "<br><br><br><h3>Sending file: ", $textReportFullPath, "</h3>\n";
print HTML_OUTPUT_FILE "<h3>Emailing to: ", $email_dest, " at ", $datestring, "</h3>\n";
print HTML_OUTPUT_FILE "<br><br><h3>Phone Instructions</h3>\n";
print HTML_OUTPUT_FILE "From phone e-mail message, select attached file and then select the 'Copy to SA Group Text' Icon.\n";
print HTML_OUTPUT_FILE "<br>From the SA Group Text application, select the 'ProvidentTextTool_output.csv' file.\n";
print HTML_OUTPUT_FILE "<br>Then, softly press on 'ProvidentTextTool_output.csv' file.\n";
print HTML_OUTPUT_FILE "<br>Click on the send icon (paper airplane icon) on the bottom right hand corner of screen to send.\n";
close (HTML_OUTPUT_FILE);





# Create and array of email parts. 
# Here i have 1 attachments and a text message.
my @parts = (
    Email::MIME->create(
        attributes => {
            filename      => $textReport,
            content_type  => "text/plain",
            encoding      => "8bit",
            disposition   => "attachment",
            Name          => $textReport
        },
        body => io($textReportFullPath)->all,
    ),
    Email::MIME->create(
        attributes => {
            content_type  => "text/html",
        },
        body => 'Provident Text Tool Report: <date>',
    )
);

print $datestring;
my $email_subject = sprintf("Provident Text Utility Report: %s",$datestring);
 
# Create the email message object.
my $email_object = Email::MIME->create(
    header => [
        From           => $email_src,
        To             => $email_dest,
        Subject        => $email_subject,
        content_type   =>'multipart/mixed' ],
    parts  => [ @parts ],
);
 
# Create the transport. Using gmail for this example
my $transport = Email::Sender::Transport::SMTP::TLS->new(
    host     => 'smtp.gmail.com',
    port     => 587,
    username => $email_src,
    password => $email_src_pw
);
 
# send the mail
try 
{
    sendmail( $email_object, {transport => $transport} );
} 
catch 
{
    warn "Email sending failed: $_";
};