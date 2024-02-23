#!/bin/bash
ERROR=0

errorArray=()

find_list(){
LIST="$(find $DIR -name "*.yml")"
}

tag_check(){
###Check DFIR Report distribution tags
DISTTAGS="dist.internal|dist.private|dist.development|dist.public|dist.deprecated"
if [ $(egrep "$DISTTAGS" $RULE | wc -m ) -lt 5 ];then
	echo -e "$RED\n[FAIL] Missing DFIR Report Distribution tag $WHITE\n\nPlease add an appropriate distribution tag: $DISTTAGS"
	ERROR=1
	errorArray+=("$RULE")
else
	echo -e "$GREEN\n[PASS] DFIR Report Requirements $WHITE\n"
fi
}

spelling_check(){
###Check for common spelling errors
MISSPELLING="Uknown"
if [ $(egrep "$MISSPELLING" $RULE | wc -m ) -gt 1 ];then
	echo -e "$RED\n[FAIL] Spelling error $WHITE\n\nPlease fix spelling for $(egrep "$MISSPELLING" $RULE)"
        ERROR=1
        errorArray+=("$RULE")
else
        echo -e "$GREEN\n[PASS] DFIR Report Requirements $WHITE\n"
fi
}

mitre_check(){
###Check mitre errors
MISSPELLING="attack.T"
if [ $(egrep "$MISSPELLING" $RULE | wc -m ) -gt 1 ];then
        echo -e "$RED\n[FAIL] MITRE tag error $WHITE\n\nPlease fix mitre tag for $(egrep "$MISSPELLING" $RULE)\n See SIGMA cli checks for additional information"
        ERROR=1
        errorArray+=("$RULE")
else
        echo -e "$GREEN\n[PASS] DFIR Report Requirements $WHITE\n"
fi
}

main(){
###Check that Sigma rule best practices followed
find_list
#echo $LIST
IFS=$'\n'
for i in $(echo "$LIST");do RULE=$(echo "$i"); echo -e "====================\nChecking rule $i\n";spelling_check;mitre_check;done
unset IFS
if [ $(echo $ERROR) -eq 1 ];then
	echo -e "\n\n[FAIL] Please address issues in report and resubmit for testing.\n====================\n"
	for error in "${errorArray[@]}"
	do 
		echo -e "[FAIL] $error"
	done
	exit 1
else
	echo -e "[PASS]"
fi
}


helpmenu(){
echo -e "-h Show Help Menu"
echo -e "-d directory to check"
}

# read the options
TEMP=`getopt -o d:h:: --long directory:,help:: -- "$@"`

eval set -- "$TEMP"

while true; do
  case "$1" in
    -h|--help)
      helpmenu
      exit 0;;
    -d|--directory)
      DIR=$2; shift 2;
      main
      exit 0;;
    *) break;;
esac
done

