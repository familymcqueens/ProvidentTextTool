 #!/usr/bin/perl
use strict;
use warnings;
use Try::Tiny;
use IO::All;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use ProvidentTextTool;

my $CFG_FILE_NAME = "ProvidentTextTool.cfg";
my $email_src     = ReadConfigFile($CFG_FILE_NAME,"email_src");
my $email_src_pw  = ReadConfigFile($CFG_FILE_NAME,"email_src_pw");
my $email_dest    = ReadConfigFile($CFG_FILE_NAME,"email_dest");
my $homeDirectory = ReadConfigFile($CFG_FILE_NAME,"home_dir");
my $textReport    = ReadConfigFile($CFG_FILE_NAME,"text_report");
my $textReportFullPath = sprintf("%s\\%s",$homeDirectory,$textReport);


my $datestring = gmtime();

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
        content_type   =>'multipart/mixed'
    ],
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