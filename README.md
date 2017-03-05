# unzipMoveSort-Tor
## Personalized Perl Script to Sort Media Between Tv Shows (Specific) and Movies 
** Work in Progress **
## PREREQS
**This is a script based on Windows platforms**
* Author: AJ Klinger - aj.klinger21@gmail.com		       
* Must have 7z.exe installed, the command line version of 7zip, the GUI Version only will not work.					        
  * Confirmed $version 9.20 and higher have it with Windows version.  												                        
* Set Env. Variable in Windows to 7z.exe unless you want to specify full path of the 7z.exe in the %zconfigs exec. 	
  * Note: Do not specify .exe in the path in the 'exec' hash alias, it won't work. 								                    	
* Tv Shows must be clear and concise with correct spelling.  Eg. 'Dexter' or 'Game of Thrones'.
* Seasons Must be in this format 'Season 1' or 'Season 01'.  														                            
  * 'Season One' with the number spelled out could work with a slight modification.  								                  
* Must have Perl Installed.  For Windows Google/install Strawberry Perl.  Linux prolly already has it installed.
* RUN from CMD after ENV VAR Set after Strawberry Perl installed: 'cpan Getopt::Long'							                  
* Normal syntax Perl (Command Line) or Windows Command C:\%PERL SCRIPT PATH% 'perl unzipMoveRename.pl			          	
## TODO (WIP)																										                                                    
* Implement a clean POD documentation for this script.  														                              
* Create a .conf file that lets others define variables and load them into the script when called 				        
* Create a soft test switch, which only produces output rather than touching files and directories				        
* A lot more to follow																							                                              											
## USE CASE	
* The primary scope at the moment is to simplify sorting and managing new torrent files rather than organizing an existing library.  
* Define a landing location for the downloaded Tor files and a destination directory for your Tv and Movie directories.  
* My current setup   uses a NAS over a LAN and this so far has worked very well, as it is mapped to a drive on the computer I execute the   script from.    
*	It should also be noted that I am a Perl noob, but great at procedural programming as I do it for a living.  This is my first real Perl   script and GitHub repo.  
* Cheers!
