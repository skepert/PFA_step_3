#!/usr/bin/perl -w

	# Print From Anywhere for Mac, print queue setup.  For use by SUNY Stony Brook Students
	# Service provided by Desktop & Systems Engineering 
	# This version by Shaun Kepert, original v1.0 by Andrew Johnson
	# Last Edit: 02/12/2022
	
use strict;
use warnings;

my $version = "v3.3.12";
my $OSversion = 1;
my $logpath = "/Library/Logs/SINC_PFAclient.log";
my $date = `/bin/date`;
my $OSmin = 7;

open(my $log, '>', $logpath) or die "Can't open $logpath";

my $pharosPath = "/Library/Application Support/Pharos/Popup.app";
my $xeroxPath = "/Library/Printers/PPDs/Contents/Resources/Xerox Phaser 7800DN.gz";
my $pharosLS = `/bin/ls -l '/Library/Application Support/Pharos' 2>&1`;
my $xeroxLS = `/bin/ls -l '/Library/Printers/PPDs/Contents/Resources/Xerox\ Phaser\ 7*' 2>&1`;

print $log "\nStarting $0 - $version\n";
print $log "$date\n";
print $log "Print From Anywhere $version, Provided by Desktop and Systems Engineering\n";
print $log "This script requires the Pharos Popup software and Xerox print drivers to be installed FIRST.\n\n";

	# OS Version check - removed, only report the OS to the log
	
$OSversion=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion`;
print $log "My OS version: $OSversion";

# $OSversion=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | /usr/bin/cut -c 1,2`;
# chomp $OSversion;

	# Are you on Big Sur?  Thanks Apple...
# if ( $OSversion == 10 ) {
#	# adjust variable for pre Big Sur MacOS X version numbering system
#	$OSversion=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | /usr/bin/cut -d \. -f 2`;
#	chomp $OSversion;
# }
# else {
#	# adjust variable for new post Big Sur version numbering system, treat 11.0 as 10.16
#	$OSversion=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | /usr/bin/cut -d \. -f 2`;
#	chomp $OSversion;
#	$OSversion = $OSversion + 16;
# }

# if ( $OSversion < $OSmin ) {
#	print $log "Your operating system version is too low, update to MacOS 10.7 or higher.\n";
#	close($log);
#	die;
# }
# else {
#	print $log "Passed minimum MacOS version check.\n";
#	print $log "Max MacOS check not run. New versions of MacOS may not be tested. Proceed with caution!\n\n";
# }

	#Check for Pharos Popup and Xerox Printer software
	
print $log "Checking for Pharos Popup and Xerox Printer software:\n";

if ( -e $pharosPath ) {
	 print $log "Pharos software appears to be installed, found:\n";
	 print $log "$pharosLS";
	 print $log "\n";
	 print $log "ps found the following processes:\n";
	 my $running=`/bin/ps -ax | grep -i pharos | grep -v grep`;
	 print $log "$running\n"
}
else {
	print $log "WARNING! Pharos software does not appear to be installed!\n";
	print $log "$pharosLS";
	print $log "\nFAILED INSTALL - Pharos Popup Software not detected\n";
	system("/bin/cat $log");
	close ($log);
	die;
}
if ( -e $xeroxPath ) {
	print $log "Xerox software appears to be installed, found:\n";
	print $log "$xeroxLS";
	print $log "\n";
}
else {
	print $log "WARNING! Xerox printer drivers do not appear to be installed!\n";
	print $log "$xeroxLS";
	print $log "\nFAILED INSTALL - Xerox Printer Drivers not detected";
	system("/bin/cat $log");
	close ($log);
	die;
}

	# Create the Print Queue if it doesn't exist. 
print $log "Checking for SINC_Print_From_Anywhere:\n";

my $queue=`/usr/bin/lpstat -v | /usr/bin/egrep -ic SINC_Print_From_Anywhere`; chomp $queue;
if ( $queue >= 1 ) {
	print $log "It looks like the Queue already exists.\n\n";
	$queue=`/usr/bin/lpstat -t 2>&1`;
	print $log "lpstat found:\n";
	print $log "$queue";
	print $log "\n";
}

else {
		# Install the print queue.
	print $log "Installing the print queue.\n";
	system("/usr/sbin/lpadmin -D 'SINC Print From Anywhere' -p SINC_Print_From_Anywhere  -v 'popup://elmo.sinc.stonybrook.edu:515/mainq_web' -E -P '$xeroxPath' -o 'PageSize/Media Size':'Letter' -o printer-is-shared=false 2>&1 >> $logpath");
		# Enabling the printer just in case.
	print $log "Enabling the print queue.\n";
	system("/usr/sbin/cupsenable \$(/usr/bin/lpstat -p | /usr/bin/grep -w 'printer' | /usr/bin/awk '{print\$2}') 2>&1 >> $logpath");
	
	$queue=`/usr/bin/lpstat -t`;
	print $log "\nlpstat found:\n";
	print $log "$queue\n";	
}
print $log "$0 - $version script complete.\n";

system ("cat $logpath");
system ("echo 'You can find the instalation log at: $logpath'");
system ("echo ''");
close($log);
exit;
