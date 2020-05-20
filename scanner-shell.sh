#!/bin/bash
#===============================================================================
#
#          FILE:  scanner.sh
# 
#         USAGE:  ./scanner.sh 
# 
#   DESCRIPTION:  An automated discovery script for conducting simple scanning techniques using nmap
#                 and other tools.
# 
#       OPTIONS:  No Options required. Just execute the program and follow the instructions in the menu.
#  REQUIREMENTS:  bash
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kai Blea
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  04/22/2018 07:17:35 PM PDT
#      REVISION:  ---
#===============================================================================

#set -x

# Set some gl0bal variables
home=$HOME
hr="============================================================================"
sip='sort -n -u -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4'


#===============================================================================

banner(){
echo 
echo -e "\x1B[1;96m
  ___  ___ __ _ _ __  _ __   ___ _ __ 
 / __|/ __/ _  |  _ \|  _ \ / _ \  __|
 \__ \ (_| (_| | | | | | | |  __/ |   
 |___/\___\__,_|_| |_|_| |_|\___|_|   

A lighweight pentesting network discovery tool.                                    
By Kai Blea

Inspired by Lee Baird's DISCOVER tool.\x1B[0m"

echo
}

#===============================================================================

# Create a generic Error Function that we can reuse later in the program.
# The Error should display something like "Invalid choice or entry"

error(){

echo "invalid choice or entry"
echo

}

#===============================================================================

# Create a User Menu for SCANNING
# The user should be able to select a arp-scan or a ping sweep

generateTargets(){
clear
banner

echo -e "\x1B[1;34mSCANNING\x1B[0m"
echo
echo "1.  LAN ARP Scan"
echo "2.  Ping sweep"
echo "3.  Previous menu"
echo
echo -n "Choice: "
read choice

# Maybe a case statement here will work. Refer to the class slides on Bash Programming
case $choice in
     1)
     arpscan
     ;;

     2)
     pingSweep
     ;;

     3)
     showMenu
     ;;

esac
}

#====================================================================================

# This is an ARP scan. This program should be available in your Kali VM.
# I won't make you write all this code so I already did it for you, but
# you have to figure out where the arp-scan should be placed.

arpscan(){  

     

     echo
     echo -n "Interface to scan: "
     read interface

     echo
     echo -n "IP Range to scan: "
     read range

     

     # Check for no answer
     if [[ -z $interface ]] || [[ -z $range ]]; then
          error
     fi 

     arp-scan --interface=$interface $range \| egrep -v '(arp-scan\|Interface\|packets\|Polycom)' \| awk '{print $1}' \| $sip \| sed '/^$/d' >$home/data/hosts-arp.txt

     echo $hr 
     echo
     echo "***Scan complete.***"
     echo
     echo
     printf 'The new report is located at \x1B[1;33m%s\x1B[0m\n' $home/data/hosts-arp.txt
     echo
     echo

showMenu

}

#===================================================================================

# This is a Ping Sweep using Nmap. This function should allow the user to 
# enter a path to an existing IP List or enter an IP Address subnet. i.e. 192.168.1.0/26
# Most of the code is there, you only need to add the nmap commands.

pingSweep(){
clear
banner

echo -e "\x1B[1;34mType of input:\x1B[0m"
echo
echo "1.  List containing IPs"
echo "2.  Manual"
echo
echo -n "Choice: "
read choice

case $choice in
     1)
     filePath

     nmap -sn -PS -PE --stats-every 10s -iL $location > tmp
     echo
     echo "Running an Nmap ping sweep for live hosts."
     ;;

     2)
     echo
     echo -n "Enter your targets: "
     read manual
     
     # Check for no answer
     if [[ -z $manual ]]; then
          error
     fi

     nmap -sn -PS -PE --stats-every 10s $manual > tmp
     echo
     echo "Running an Nmap ping sweep for live hosts."
     ;;

     *) error;;
esac

cat tmp | grep 'report' | awk '{print $6}' | tr -d '()' > tmp2
mv tmp2 $home/data/hosts-ping.txt
rm tmp

echo
echo $hr
echo
echo "***Scan complete.***"
echo
echo
printf 'The new report is located at \x1B[1;33m%s\x1B[0m\n' $home/data/hosts-ping.txt
echo
echo
showMenu

}

#====================================================================================

showlist(){
clear
banner

echo
echo -e "\x1B[1;34mTARGET LISTS\x1B[0m"
echo
echo "1. ARP Scan List"
echo "2. Ping Sweep List"
echo "3. Return to Main Menu"
echo
echo -n "Choice: "
read choice

case $choice in
     1) 
     if [ ! -e $home/data/hosts-arp.txt ]; then
        echo -e "\x1B[1;31m Target list does not exists! \x1B[0m"
        main
     fi

       echo $hr 
       echo -e "\x1B[1;31m                *** Current Target ARP List ***\x1B[0m"

       # Display the ARP list   

       echo $hr
       echo 
       showMenu
     ;;
     2) 
     if [ ! -e $home/data/hosts-ping.txt ]; then
        echo -e "\x1B[1;31m Target list does not exists! \x1B[0m"
        main
     fi
 
       echo $hr 
       echo -e "\x1B[1;31m                *** Current Target Ping List ***\x1B[0m"

       # Display the Ping List

       echo $hr
       echo
       showMenu
     ;;
     3) main;;
     *) error;;
esac

}

#===================================================================================

filePath(){

echo
echo -n "Enter the path to your file: "
read -e location

# Check for no answer
if [[ -z $location ]]; then
     error
fi

# Check for wrong answer
if [ ! -f $location ]; then
     error
fi

}

#===================================================================================

showMenu(){

echo
echo -e "\x1B[1;34mSCANNING\x1B[0m"
echo
echo "1.  Generate Target List"
echo "2.  Show Target List"
echo "3.  Exit"
echo
echo -n "Choice: "
read choice

case $choice in
     1) generateTargets;;
     2) showlist;;
     3) clear && exit;;
     *) error;;
esac

}

#====================================================================================

main(){
clear
banner

if [ ! -d $home/data ]; then
     mkdir -p $home/data
fi

showMenu

}

#=========================================================================================

# Run Main Function
main
