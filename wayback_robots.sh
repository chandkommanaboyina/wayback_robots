waybackrobots_from_file() {
file=$1
mkdir robots  2>/dev/null
cd robots
for line in $(cat ../${file})
do
waybackrobots "$line"
done
out(){
dir_out=$1
mkdir $dir_out 2>/dev/null
mv robots/*  $dir_out
}
}

waybackrobots() {
line=$1 
echo -e "\e[31m Started checking for old urls for ${line} \e[0m"
curl -s "https://web.archive.org/cdx/search/cdx/%20?url=${line}/robots.txt&output=txt&fl=timestamp,original&filter=statuscode:200&collapse=digest" |  sed 's/ /\//' >  waybackrobots.txt  2>/dev/null
for robots in $(cat waybackrobots.txt)
do
lynx -dump  "https://web.archive.org/web/${robots}" > temp.txt  2>/dev/null
if grep -q "Disallow:" temp.txt; then
cat temp.txt |grep -v "User-agent:" | grep -v "//" | sed 's/.*: //' |sed 's/ .*//' | sed "s|^|https://${line}|" |grep "${line}/"|  sort -u | tee -a ${line}.txt
fi
rm temp.txt  2>/dev/null
done
cat  ${line}.txt  2>/dev/null |grep "${line}/"| sort -u > ${line}_robots.txt
rm ${line}.txt  waybackrobots.txt  2>/dev/null
echo -e "\e[32m $(cat ${line}_robots.txt 2>/dev/null | wc -l) found for ${line} \e[0m"  
echo -e "\e[34m -------------------------------------------------------------------------------------------------------------------------------- \e[0m"
}

for_help(){
 echo -e "${PADDING}${BOLD}USAGE: ${RESET} ./wayback_robots.sh [options..] [parameter..]"
 echo -e "\t\t\t    ${PADDING}${BOLD}-d,${RESET} --domain\t domain name to crawl"
 echo -e "\t\t\t    ${PADDING}${BOLD}-f,${RESET} --filename\t file name which contains domains to crawl"
 echo -e "\t\t\t    ${PADDING}${BOLD}-o,${RESET} --output\t name/path to the folder to save output(only applicable for -f or --filename argument)"
 echo -e "\t\t\t    ${PADDING}${BOLD}-h,${RESET} --help\t\t To show this help message"

}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d |--target) target="$2"; waybackrobots "$2";  shift ;;
        -f |--filename)  filename="$2" ;waybackrobots_from_file "$2" ; shift;; 
        -o |--output) output="$2"; out "$2"; shift ;;
        -h |--help) for_help ;;
        *) echo -e "Unknown argument passed:\e[31m  $1 \e[0m  ";echo -e "For more information try \e[32m  ./wayback_robots.sh --help \e[0m  or \e[32m  ./wayback_robots.sh -h \e[0m  "; exit 1 ;;
     esac
    shift
done
