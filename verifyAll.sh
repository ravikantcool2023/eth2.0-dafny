#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

error=0
processedfiles=0

myfiles=()
mystatus=()

# help and usage
help()
{
   # Display Help
   echo "Usage: $0 dir, where dirname is the folder you want to check."
   echo "All .dfy files in the folder dirname will be checked."
   echo
}

# Check number of arguments
if  [ "$#" -ne 1 ];  
    then 
    echo "Illegal number of parameters"
    help
    exit 1
fi

if [ ! -d "$1" ] 
then
    echo -e "${RED}Error: Directory $1 DOES NOT exists.${NC}" 
    exit 2 
fi

# try to process files in the directory $1
for entry in "$1"/*.dfy
do
  # check file exists (this can occur if directory does not have *.dfy files)
  [ -f "$entry" ] || continue
  processedfiles=$((processedfiles + 1))
  echo -e "${BLUE}-------------------------------------------------------${NC}"
  echo -e "${BLUE}Processing $entry${NC}"
  myfiles+=($entry)
  dafny3 /dafnyVerify:1 /compile:0 /tracePOs /traceTimes /timeLimit:40 /noCheating:0 /vcsCores:10 "$entry"
  # echo "$result"
  if [ $? -eq 0 ] 
  then
      echo -e "${GREEN}No errors in $entry${NC}"
      mystatus+=(1)
  else
      echo -e "${RED}Some errors occured in $entry${NC}"
      error=$((error + 1))
      mystatus+=(0)
  fi
done

for i in ${!myfiles[@]}; do
  if [ ${mystatus[$i]} -ne 1 ]
  then
    echo -e "${RED}[FAIL] ${myfiles[$i]} has some errors :-(${NC}"
  else 
     echo -e "${GREEN}[OK] ${myfiles[$i]}${NC}" 
  fi
done

if [ $error -ne 0 ]
then
  echo -e "Summary: ${RED}Some files [$error/$processedfiles] has(ve) errors :-("
  exit 1
else 
  echo -e "Summary: ${GREEN}$processedfiles files processed - No errors occured! Great job.${NC}"
  exit 0
fi



