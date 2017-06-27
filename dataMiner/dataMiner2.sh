#!/bin/bash
# FortiSIEM Backend Data Miner
# cdurkin@fortinet.com
# Version 2.0
# May 2017

RED='\033[31m'
BLUE='\033[34m'
GREEN='\033[32m'
NC='\033[0m'
BOLD='\033[1m'
NOBOLD='\033[0m'
CYAN='\033[36m'

rm -rf newfile.txt

echo ""
echo -e "${BLUE}(c) 2017 Fortinet PS - FortiSIEM Backend Data Miner (2.0)\n"
echo -e "████████▄     ▄████████     ███        ▄████████   ▄▄▄▄███▄▄▄▄    ▄█  ███▄▄▄▄      ▄████████    ▄████████" 
echo -e "███   ▀███   ███    ███ ▀█████████▄   ███    ███ ▄██▀▀▀███▀▀▀██▄ ███  ███▀▀▀██▄   ███    ███   ███    ███" 
echo -e "███    ███   ███    ███    ▀███▀▀██   ███    ███ ███   ███   ███ ███▌ ███   ███   ███    █▀    ███    ███" 
echo -e "███    ███   ███    ███     ███   ▀   ███    ███ ███   ███   ███ ███▌ ███   ███  ▄███▄▄▄      ▄███▄▄▄▄██▀" 
echo -e "███    ███ ▀███████████     ███     ▀███████████ ███   ███   ███ ███▌ ███   ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀▀  " 
echo -e "███    ███   ███    ███     ███       ███    ███ ███   ███   ███ ███  ███   ███   ███    █▄  ▀███████████" 
echo -e "███   ▄███   ███    ███     ███       ███    ███ ███   ███   ███ ███  ███   ███   ███    ███   ███    ███" 
echo -e "████████▀    ███    █▀     ▄████▀     ███    █▀   ▀█   ███   █▀  █▀    ▀█   █▀    ██████████   ███    ███" 
echo -e "                                                                                               ███    ███" 
echo -e "${NC}"

total=0

if [ ! -e "allRules.xml" ]; then
   cat /opt/phoenix/data-definition/rules/*.xml > allRules.xml
   ruleXmlFile=allRules.xml
   cp $ruleXmlFile newfile_rule.txt
   sed -i '/^$/d' newfile_rule.txt
   sed -i '/<\/Rule>/a###' newfile_rule.txt
   sed -i '/<Rules>/d' newfile_rule.txt
   sed '/<TriggerEventDisplay>/,/<\/TriggerEventDisplay>/{//!d;}' newfile_rule.txt > rulefile.txt
fi

if [ ! -e "allReports.xml" ]; then
   cat /opt/phoenix/data-definition/reports/*.xml > allReports.xml
   reportXmlFile=allReports.xml
   cp $reportXmlFile newfile_report.txt
   sed -i '/^$/d' newfile_report.txt
   sed -i '/<\/Report>/a###' newfile_report.txt
   sed '/<Reports>/d' newfile_report.txt > reportfile.txt
fi

if [ ! -e "allBaseline.xml" ]; then
   cat /opt/phoenix/data-definition/reports/BASELINE_REPORTS.xml > allBaseline.xml
   reportXmlFile=allBaseline.xml
   cp $reportXmlFile newfile_baseline.txt
   sed -i '/^$/d' newfile_baseline.txt
   sed -i '/<\/Report>/a###' newfile_baseline.txt
   sed '/<Reports>/d' newfile_baseline.txt > baselinefile.txt
fi

if [ ! -e "allStatRules.xml" ]; then
   cat /opt/phoenix/data-definition/rules/STAT_RULES.xml > allStatRules.xml
   reportXmlFile=allStatRules.xml
   cp $reportXmlFile newfile_stat.txt
   sed -i '/^$/d' newfile_stat.txt
   sed -i '/<\/Rule>/a###' newfile_stat.txt
   sed -i '/<Rules>/d' newfile_stat.txt
   sed '/<TriggerEventDisplay>/,/<\/TriggerEventDisplay>/{//!d;}' newfile_stat.txt > statfile.txt
fi

if [ ! -e "watchLists.txt" ]; then
   psql -t -U phoenix -d phoenixdb -c "select natural_id,display_name from ph_group where natural_id like 'PH_DYNLIST_%';" > watchLists.txt
fi

if [ ! -e "device_values.txt" ]; then
   psql -t -U phoenix -d phoenixdb -c "select property_name, display_name  from ph_cust_property_def where value_type !='0';" > device_values.txt
   sed -i 's/^ *//g' device_values.txt
fi

rule_content=$(cat rulefile.txt)
report_content=$(cat reportfile.txt)
baseline_content=$(cat baselinefile.txt)
statrule_content=$(cat statfile.txt)

rules_menu(){
IFS='###'
word_regex=".*$word.*"
for value in $rule_content
do
  if [[ $value =~ $word_regex ]]; then
     remove_name=$(echo $value | grep -v "<Name>")
     remove_desc=$(echo $remove_name | grep -v "<Description>")
     if [[ $remove_desc =~ $word_regex ]]; then
        matches=( "${matches[@]}" $(echo $value) )
     fi
  fi
done

PS3='Please select an option: '
options=("Option 1 - Rule Names Only" "Option 2 - Rules and Details" "Option 3 - Identify WatchLists" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1 - Rule Names Only")
            IFS=$'\n'
            for i in "${matches[@]}"
            do
               if [[ $i =~ \<Name\> ]]; then
               ruleName=$(echo $i | grep -oP '(?<=Name>)[^<]+')
               total=$((total+1))
               echo -e "${BLUE}Match $total: ${RED}$ruleName${NC}"
               fi
            done
            break
            ;;
        "Option 2 - Rules and Details")
            IFS=$'\n'
            for i in "${matches[@]}"
            do
              if [[ $i =~ \<Name\> ]]; then
                 ruleName=$(echo $i | grep -oP '(?<=Name>)[^<]+')
                 total=$((total+1))
                 echo -e "##${BLUE}Match $total${NC}#################################################"
                 echo -e "\n${RED}Rule Name: $ruleName${NC}"
              fi
              if [[ $i =~ \<Description\> ]]; then
                 ruleDescription=$(echo $i | grep -oP '(?<=Description>)[^<]+')
                 echo "Rule Description: $ruleDescription"
              fi

              multiplepatterncheck=$(echo $i | grep -o "SubPattern displayName" | wc -l)

              if [[ $multiplepatterncheck -eq "1" ]]; then
                 echo -e "${BLUE}SINGLE Pattern Rule......${NC}"
              elif [[ $multiplepatterncheck -ge "2" ]]; then
                 echo -e "${BLUE}MULTIPLE Pattern Rule......${NC}"
              fi

              allpatterns=$(echo "$i" | grep -Pzo '<PatternClause window(\n|.)*(?=</PatternClause>)')

              for (( c=1; c<=$multiplepatterncheck; c++ ))
                do
                   pattern=$(echo "$allpatterns" | awk '/SubPattern displayName/{i++}i=='$c'')
                   pattern_name=$(echo "$allpatterns" | awk '/SubPattern displayName/{i++}i=='$c'' | grep -Po 'SubPattern displayName="\K[^"]+')
                   echo -e "${GREEN}SubPattern Name : $pattern_name${NC}"
                   echo -e "Subpattern ${BOLD}Condition${NOBOLD} Match:"
                   #subpattern_result=$(echo "$pattern" | sed -n 's:.*<SingleEvtConstr>\(.*\)</SingleEvtConstr>.*:\1:p' | sed -e 's/^\s*//' | grep --color $word)
                   subpattern_result=$(echo "$pattern" | awk '/<SingleEvtConstr>/,/<\/SingleEvtConstr>/' | sed 's/<SingleEvtConstr>//g' | sed 's/<\/SingleEvtConstr>//g' | sed -e 's/^\s*//' | grep --color $word)                   
                   if [ -z "$subpattern_result" ]; then
                      echo "No Match"
                   else
                      echo "$subpattern_result" | grep --color $word
                   fi

                   echo -e "\nSubPattern ${BOLD}GroupBy${NOBOLD} Match: "
                   groupby_result=$(echo -n "$pattern" | sed -e 's/^\s*//' | grep -Pzo '<GroupByAttr>(\n|.)*(?=</GroupByAttr>)' | sed -r 's/^.{13}//' | grep --color $word)
                   if [ -z "$groupby_result" ]; then
                      echo "No Match"
                   else
                      echo "$groupby_result" | grep --color $word
                   fi
                   echo ""

                   echo -e "SubPattern ${BOLD}Aggregation${NOBOLD} Match: "
                   aggregation_result=$(echo -n "$pattern" | awk '/<GroupEvtConstr>/,/<\/GroupEvtConstr>/' | sed 's/<GroupEvtConstr>//g' | sed 's/<\/GroupEvtConstr>//g' | sed -e 's/^\s*//' | grep --color $word)
                   if [ -z "$aggregation_result" ]; then
                      echo "No Match"
                   else
                      echo "$aggregation_result" | grep --color $word
                   fi
                   echo ""

                   if [[ $i =~ \<WatchList\> ]]; then
                      watchList=$(echo $i | grep -oP '(?<=DynWatchListDef attr=")[^"]+')
                      watchList_Name=$(echo $i | grep -oP '(?<=WatchList>)[^<]+')
                      watchList_Name=`echo $watchList_Name | sed 's/ *$//g'`
                      if [[ "$watchList" == "$word" ]]; then
                         echo -e "${BOLD}${RED}$word${NC}${NOBOLD} is added to ${BOLD}Watch List${NOBOLD} : ${CYAN}$watchList_Name${NC}"
                         resolve_name=$(grep "$watchList_Name" watchLists.txt | cut -d "|" -f 2)
                         echo -e "The Actual Watch List Name is ${CYAN}$resolve_name${NC}\n"
                      fi
                   fi

               done
                   echo -e "Rule ${BOLD}Incident Attributes${NOBOLD} Match: "
                   #echo -n $i | grep -Pzo '<ArgList>(\n|.)*(?=</ArgList>)' | sed -r 's/^.{13}//' | sed -e 's/^\s*//' | grep --color $word
                   incident_result=$(echo "$i" | awk '/<ArgList>/,/<\/ArgList>/' | sed 's/<ArgList>//g' | sed 's/<\/ArgList>//g' | sed -e 's/^\s*//' | grep --color $word)
                   if [ -z "$incident_result" ]; then
                      echo "No Match"
                   else
                      echo "$incident_result" | grep --color $word
                   fi
                   echo ""
           done
           break
           ;;
         "Option 3 - Identify WatchLists")
            IFS=$'\n'
            for i in "${matches[@]}"
            do
               if [[ $i =~ \<Name\> ]] && [[ $i =~ \<WatchList\> ]]; then
                  watchList=$(echo $i | grep -oP '(?<=DynWatchListDef attr=")[^"]+')  
                  watchList_Name=$(echo $i | grep -oP '(?<=WatchList>)[^<]+')
                  watchList_Name=`echo $watchList_Name | sed 's/ *$//g'`
                  if [[ "$watchList" == "$word" ]]; then
                     ruleName=$(echo $i | grep -oP '(?<=Name>)[^<]+')
                     total=$((total+1))
                     echo -e "${BLUE}Match $total: ${RED}$ruleName${NC}"
                     resolve_name=$(grep "$watchList_Name" watchLists.txt | cut -d "|" -f 2) 
                     echo -e "Watch List $total: ${CYAN}$watchList_Name${NC}, GUI Name: ${CYAN}$resolve_name${NC}\n"
                  fi
               fi
            done
            break
            ;;
        "Quit")
            exit 1
            ;;
        *) echo invalid option;;
    esac
done
   
echo -e "##END######################################################"
echo -e "\nSummary: There are $total matches\n"
exit 1
}

reports_menu(){
IFS='###'
word_regex=".*$word.*"
for value in $report_content
do
  if [[ $value =~ $word_regex ]]; then
     remove_name=$(echo $value | grep -v "<Name>")
     remove_desc=$(echo $remove_name | grep -v "<Description>")
     if [[ $remove_desc =~ $word_regex ]]; then
        matches=( "${matches[@]}" $(echo $value) )
     fi
  fi
done

PS3='Please select an option: '
options=("Option 1 - Report Names Only" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1 - Report Names Only")
            IFS=$'\n'
            for i in "${matches[@]}"
            do
               if [[ $i =~ \<Name\> ]]; then
               reportName=$(echo $i | grep -oP '(?<=Name>)[^<]+')
               total=$((total+1))
               echo -e "${BLUE}Match $total: ${RED}$reportName${NC}"
               fi
            done
            break
           ;;            
        "Quit")
            exit 1
            ;;
        *) echo invalid option;;
    esac
done
   
echo -e "##END######################################################"
echo -e "\nSummary: There are $total matches\n"
exit 1
}



PS3='Please select the DataMiner Mode: '
options=("Rule Attribute Query" "CMDB Device Property Rule Query" "CMDB Event Type Search/Export" "Report Attribute Query" "Baseline Rule/Report Listing" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Rule Attribute Query")
            echo -e "What Attribute do you want to search for? : ${RED}"
            read word
            echo -e "${NC}"            
            rules_menu
            ;;
        "CMDB Device Property Rule Query")
            echo -e "Type a few characters (as per the GUI) of the Property to search for? (ie: Disk or CPU) : "
            read query
            echo -e ""
            readarray query_targets < <(grep "$query" device_values.txt)
            length=${#query_targets[@]}
            
            echo -e "${BOLD}Query Results${NOBOLD} : \n"
            for ((i = 0; i != length; i++)); do
               echo -en "Value ${RED}$i${NC}: ${query_targets[i]}"
            done

            echo -en "Select the result ${BOLD}number${NC} to search for? (ie: 0) : "
            read querynumber
           
            word_temp=$(echo ${query_targets[$querynumber]} | cut -d "|" -f 1)
            word=`echo $word_temp | sed 's/\s*$//'`
            echo -e ""

            rules_menu
            ;;
        "CMDB Event Type Search/Export")

            echo -e "Do you want to query eventTypes for a Specific Device or All Devices? (SD or All) : ${RED}"
            read cmdbsearch
            echo -e "${NC}"
            
            if [[ $cmdbsearch =~ ^(S|s|SD|sd|specific|Specific) ]]; then
               
              OUTPUT=0
              vendor=1
              model=1
              while [ `psql -U phoenix -d phoenixdb -t -c "select vendor, model from ph_device_type where vendor ilike '%$vendor%' and model ilike '%$model%';" | sed 's/\([^ ]*\)\s|\s*\(.*\)\s/\1,\2/' | sed '$ d' | wc -l` = 0 ]; do
                echo -e "Type a few characters of the Vendor to search for? (ie: Fort, win) : "
                read vendor
                echo -e ""
                echo -e "Now a few characters of the Model to search for? (ie: web, Box) : "
                read model
                echo -e ""
             done  
                              
              readarray cmdb_targets < <(psql -U phoenix -d phoenixdb -t -c "select vendor, model from ph_device_type where vendor ilike '%$vendor%' and model ilike '%$model%';" | sed 's/\([^ ]*\)\s|\s*\(.*\)\s/\1,\2/' | sed '$ d')
              length=${#cmdb_targets[@]}
              
              echo -e "${BOLD}Query Results${NOBOLD} : "
              echo "Item,Vendor,Model"
              echo "-------------------"
              for ((i = 0; i != length; i++)); do
                echo -e "No: ${RED}$i${NC}:${cmdb_targets[i]}"
              done

              echo -e ""
              echo -e "Select the item ${BOLD}number${NC} to search for? (ie: 0) : "
              read querynumber
             
              vendor_final=$(echo ${cmdb_targets[$querynumber]} | cut -d "," -f 1 | sed 's/[ \t]*$//')
              model_final=$(echo ${cmdb_targets[$querynumber]} | cut -d "," -f 2 | sed 's/[ \t]*$//')

              echo -e "How many results to display? : (ie: 10)"
              read limitno

              PS3='Please select an option: '
              newoptions=("Query Event Type, Name, Description Only" "Query Event Type, Name, Description only with CVE Entry" "Quit")
              select opt in "${newoptions[@]}"
              do
                case $opt in
                 "Query Event Type, Name, Description Only")
                    mode="EventOnly"
                    search=$(psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' AND model='$model_final' limit $limitno;")
                    break
                ;;
                "Query Event Type, Name, Description only with CVE Entry")
                    mode="CVE"
                    search=$(psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity,ph_event_type.cve_codes from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' AND model='$model_final' AND ph_event_type.cve_codes !='' limit $limitno;") 
                    break
                ;;
                "Quit")
                  exit 1
                ;;
                *) echo invalid option;;
              esac
            done

              #Display Search Results...
              echo "${search}"
              
              echo -e "Export the results as CSV? : (yes/no)"
              read export
             
              if [[ $export =~ ^(No|NO|n) ]]; then
               exit 1
              fi

              echo -e "All results or just the limited query results? : (all/limited)" 
              
              PS3='Please select an option: '
              queryoptions=("All results" "Just the query results" "Quit")
              select opt in "${queryoptions[@]}"
              do
                case $opt in
                 "All results")
                    now=$(date +"%m-%d-%Y-%H_%M_%S")
                    filename="All_${vendor_final}_${model_final}_eventTypes_$now.csv"
                  
                    if [[ $mode == "EventOnly" ]]; then 
                        psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' and model='$model_final';" -o $filename -F ',' -A
                    else
                        psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity,ph_event_type.cve_codes from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' and model='$model_final' AND ph_event_type.cve_codes !='';" -o $filename -F ',' -A

                    fi
                    echo -e "Data has been exported as CSV in the filename: $filename"

                    exit 1
                ;;

                 "Just the query results")
                    now=$(date +"%m-%d-%Y-%H_%M_%S")
                    filename="Sample_${vendor_final}_${model_final}_eventTypes_$now.csv"
                    
                    if [[ $mode == "EventOnly" ]]; then              
                        psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' and model='$model_final' limit $limitno;" -o $filename -F ',' -A
                    else
psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity,ph_event_type.cve_codes from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id AND vendor='$vendor_final' and model='$model_final' AND ph_event_type.cve_codes !='' limit $limitno;" -o $filename -F ',' -A
                    fi
                    echo -e "Data has been exported as CSV in the filename: $filename"
                    exit 1
                ;;
                "Quit")
                  exit 1
                ;;
                *) echo invalid option;;
              esac
            done 
            
          elif [[ $cmdbsearch =~ ^(All|A|ALL|all| ) ]]; then
             echo ""

             now=$(date +"%m-%d-%Y-%H_%M_%S")
             filename="All_eventTypes_$now.csv"

             #All Events - Name, Description, Vendor, Model, Severity
             psql -U phoenix -d phoenixdb -c "select ph_event_type.name,ph_event_type.description,ph_device_type.vendor,ph_device_type.model,ph_event_type.severity from ph_device_type, ph_event_type where ph_event_type.device_type_id = ph_device_type.id;" -o $filename -F ',' -A
             echo -e "Data has been exported as CSV in the filename: $filename"
          fi
            
            exit 1
            ;;
        "Report Attribute Query")
            echo -e "What Attribute do you want to search for? : ${RED}"
            read word
            echo -e "${NC}"
            reports_menu
            ;;
        "Baseline Rule/Report Listing")
            IFS='###'
            word_regex=".*_PROF_.*"
            for value in $baseline_content
            do
             if [[ $value =~ $word_regex ]]; then
              extract_prof_num=$(echo $value | grep -oP '(?<=eventType = ")[^"]+' | cut -d "_" -f 4)
              reportName=$(echo $value | grep -oP '(?<=Name>)[^<]+')
              echo -e "##${BLUE}Profile Number: ${BOLD}$extract_prof_num${NC}${NOBOLD}############################################"
              echo -e "\n${RED}Baseline Report: $reportName${NC}\n" 
              profile_regex=".*:$extract_prof_num.*"
              for value in $statrule_content
               do
                if [[ $value =~ $profile_regex ]]; then
                ruleName=$(echo $value | grep -oP '(?<=Name>)[^<]+')
                echo -e "Referenced in Rule: ${GREEN}$ruleName${NC}\n"
                fi
                done
             fi
           done
           
           read -r -p "Enter the Profile number to see its definition, or Press Enter to Quit : " response
           response=${response,,}           
           if [[ $response =~ ^[0-9]{3}$ ]]; then
              echo -e "Profile ${RED}$response${NC} is :- \n"
              sed -n "/id=\"$response\"/,/\/DataRequest/p" /opt/phoenix/data-definition/profile/ProfileReports.xml
           else
              exit 1
           fi

           exit 1

            ;;
        "Quit")
            exit 1
            ;;
        *) echo invalid option;;
    esac
done

