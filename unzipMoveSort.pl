use warnings; #Always add these 2 lines to new scripts #
use strict; #Always add these 2 lines to new scripts   #
#use 5.010; #Optional version declaration. 			   #
########################################################

################PREREQs#################################
#*****This is a script based on Windows platforms******#
# Author: AJ Klinger - aj.klinger21@gmail.com		   #
#####################################################################################################################
#Must have 7z.exe installed, the command line version of 7zip, the GUI Version only will not work.					#
	#Confirmed $version 9.20 and higher have it with Windows version.  												#
#Set Env. Variable in Windows to 7z.exe unless you want to specify full path of the 7z.exe in the %zconfigs exec. 	#
	#Note: Do not specify .exe in the path in the 'exec' hash alias, it won't work. 								#	
#Tv Shows must be clear and concise with correct spelling.  Eg. 'Dexter' or 'Game of Thrones'						#
#Seasons Must be in this format 'Season 1' or 'Season 01'.  														#
	#'Season One' with the number spelled out could work with a slight modification.  								#
#Must have Perl Installed.  For Windows Google/install Strawberry Perl.  Linux prolly already has it installed		#
	#RUN from CMD after ENV VAR Set after Strawberry Perl installed: 'cpan Getopt::Long'							#
	#Normal syntax Perl (Command Line) or Windows Command C:\%PERL SCRIPT PATH% 'perl unzipMoveRename.pl			#	
#####################################################################################################################

#####################################################################################################################								
#TODO (WIP):																										#
#	- Implement a clean POD documentation for this script.  														#
#	- Create a .conf file that lets others define variables and load them into the script when called 				#
#	- Create a soft test switch, which only produces output rather than touching files and directories				#
#	- A lot more to follow																							#															
#####################################################################################################################

#####################################################################################################################								
#USE CASE:	The primary scope at the moment is to simplify sorting and managing new torrent files rather than  -	#
#		Organizing an existing library.  Define a landing location for the downloaded Tor files and a  -			#
#		Destination directory for your Tv and Movie directories.  My current setup uses a NAS over a LAN and this - #
#		So far has worked very well, as it is mapped to a drive on the computer I execute the script from.			#
#		It should also be noted that I am a Perl noob, but great at procedural programming as I do it for a  -		#
#		Living.  This is my first real Perl script and GitHub repo.  Cheers!										#
#####################################################################################################################
	
use File::Spec::Functions qw(splitpath rel2abs);
use File::Path qw(mkpath remove_tree);
use IO::All;
use Text::Trim qw(trim);
use Archive::Unrar qw(list_files_in_archive);
use File::Copy qw(move);
use Getopt::Long qw(GetOptionsFromString);

my $source = "Z:/Shared Videos/Processing/";
my $destination = "Z:/Shared Videos/";
my $identifiedShow;	
my $identifiedSeason;
my $myDestination;
my $seasonEpisode;
my $season;
my $episode;
my $unRarArg;
my $rarFile;

my %zconfigs = ( 
	'exec' => "7z", 
	'source' => "Z:/Shared Videos/Processing/", 
	'destin' => "" 
	); 	
	
#my @optionlist = (

opendir (DH, $source) or die "Problem opening directory: $source because: $!";

#Adjust these expressions as needed if something is missing
my $tv_pattern = '\.S[0-9]{1,2}E[0-9]{1,2}\.';
my $movie_pattern = '\.(brrip|dvdrip|xvid|dvdscr|hdrip|webrip|bluray|web-dl|hd-vod)\.';
my $file_extensions = '\.(mkv|avi|mp4|rar|m4v)$';
my $subt_extensions = '\.(ssa|srt|sub$)';
		
while(my $object = readdir(DH)) {		
	chomp $object;
	next if $object eq $source or $object eq ".." or $object eq "." or not defined $object;	
	print "Working on $object...\n";	
	if ((-d $source.$object) or (-f $source.$object and $object =~ /$file_extensions/i)) {
		print "$object is a directory or known file type \n";
		print "DEBUG: ", $object =~ s/(\s+)/\./rg, "\n";
		$zconfigs{source} .= $object;
		print "The new Source Dir is: $zconfigs{source}\n";
		if ($object =~ s/(\s+)/\./rg =~ /$tv_pattern/) {
			print "This is a directory for a TV Show!\n";
			$destination .= "Tv Shows/";
			print $destination, "\n";
			$destination .= identify_tv_directory($object, $destination);			
			print "The new destinaion is: $destination\.\n";
			if (defined $seasonEpisode) {
				$destination .= identify_tv_season();
				$zconfigs{destin} = $destination;				
				} else {
					$zconfigs{destin} = $destination;
					}
			print "The new destination is: $zconfigs{destin}\.  Decompressing\!\n";
						
			unrar();
			}
		elsif ($object =~ s/(\s+)/\./irg =~ /$movie_pattern/i) {
				print "This is a Movie!\n";
				$destination .= "Movies/";
				$zconfigs{destin} = $destination;
				print $destination, "\n";
				print "Moving file from $zconfigs{source} to\.\.\.$zconfigs{destin}";
				#Movies for this intent and purpose do not come zipped/rar'd etc. 
				#TODO:  Check for Rar content.				
					if (-d $source.$object) {
						#delete samples. 
						opendir (SAMP, $zconfigs{source}) or die "Problem opening directory: $source because: $!";
						while (my $sampObject = readdir(SAMP)) {
							chomp $sampObject;
								if ($sampObject =~ /^Sample$file_extensions$/i) {									
									unlink $zconfigs{source} . "/" . $sampObject or die "Could not delete file: $zconfigs{source} "."$sampObject: $!\n";
									print "$zconfigs{source}/$sampObject has been deleted.\n";
									}
								}
						closedir (SAMP);
							}
				move($zconfigs{source}, $zconfigs{destin}.$object) or die "Move failed: $!";   		
			}
		else {
			next;
			}
	} else {
		if (-f $source.$object or $source.$object =~ /^sample$file_extensions$/) {		
			print "\t$object: is a plain file, deleting...\n";
			delete_object($source, $object);
			}
		}	
	#Reset the destination var for the next working group. 
	$destination = "Z:/Shared Videos/";
	$identifiedShow = undef;
	$zconfigs{source} = "Z:/Shared Videos/Processing/";
}	

sub delete_object {
	unless ($_[1] =~ /$file_extensions/i) {
		unlink $_[0].$_[1] or die "Could not delete file: $_[1]\n";
		print "$_[1] has been deleted. \n";
			}
	}
	
#Only the working object from the main procedure should be passed in here. 	
sub identify_tv_directory {
	print "identifying tv directory for $_[0]..\n";	
	$_[0] =~ s/\s+/\./g;
	my @splitObject = split /\./, $_[0];	
	$myDestination = $_[1];
	OUTER:
	for my $stringVar (@splitObject[0..$#splitObject]) {
		print $stringVar, "\n";
		if ($stringVar =~ /^S[0-9]{1,2}E[0-9]{1,2}$/) {	
			$seasonEpisode = trim($stringVar);
			last OUTER;
		} 
	$identifiedShow .= $stringVar. " ";									
	}
	
	print "The Show to Match is: $identifiedShow\n";	
	chomp $identifiedShow;
	opendir (TVDH, $myDestination) or die "Could not open directory $myDestination: $!\n";
	while (my $tvObject = readdir(TVDH)) {
		chomp $tvObject;
		next if $tvObject eq ".." or $tvObject eq "." or not defined $tvObject;	
		if (-d $myDestination.$tvObject) {	
			print "Trying to match ", lc $tvObject, " against ", lc $identifiedShow, "\n";
			if (lc trim($tvObject) eq lc trim($identifiedShow)) {
				print "We have a match\! $tvObject\n";				
				return trim($tvObject);	
				close (TVDH);				
					}
				} 
			}	
	close (TVDH);	
	}

sub identify_tv_season {
		print "Identifying Season and Episode for $identifiedShow\n";
		opendir (TVSEASON, $destination) or die "Could not open directory $destination: $!\n";
		$season  = "Season ".substr $seasonEpisode, 1,2;
		$season =~ s/0+//g;
	    $episode = "Episode ".substr $seasonEpisode, 4,5;
		$episode =~ s/0+//g;
		print "The season is $season\.\n";
		print "The episode is $episode\.\n";
		while (my $seasonObject = readdir(TVSEASON)) {
			chomp $seasonObject;
			next if $seasonObject eq ".." or $seasonObject eq "." or not defined $seasonObject;	
				print "Matching $seasonObject..\n";
				if (lc trim($seasonObject) eq lc trim($season)) {
					return "/".$season
					}
			}
		close (TVSEASON);
		}

sub unrar {
	print "Unrar File to $zconfigs{destin}\.\.\.\n";
	opendir (RARDH, $zconfigs{source}) or die "Could not open Rar Dir: $zconfigs{destin}: $!\n";
	while (my $rarObject = readdir(RARDH)) {
		$rarFile = $rarObject;
		chomp $rarFile;
		if ($rarFile =~ /\.rar$/) {			
			$unRarArg = "$zconfigs{exec} -y e \"$zconfigs{source}/$rarFile\" -o\"$zconfigs{destin}\"";
			#Use system to call zip command line execution.  
				#System will wait until its done to move onto the next file.  
			print "Found rar File: $rarFile attempting to decompress\n";
			print "Executing Command: $unRarArg\n";
			system ($unRarArg) == 0 
				or die "Descompression failed: $?";			
			remove_tree ("$zconfigs{source}");
			#system $zconfigs{exec} " -y e " $zconfigs{source} " -o" $zonfigs{destin} or die "Descompression failed: $?";
			}
		}
	$rarFile = undef;	
	close (RARDH);
	}
	
close (DH);

