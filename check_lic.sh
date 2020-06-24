#!/usr/bin/bash

/bin/clear
. ./.COLORS

case $1 in
  d) dateNEXT=`date -d "+1 day" +%s`
     INTERVAL="day"
     ;;
  w) dateNEXT=`date -d "+1 week" +%s`
     INTERVAL="week"
     ;;
  m) dateNEXT=`date -d "+1 month" +%s`
     INTERVAL="month"
     ;;
  *) echo -e "You have to provide an argument to this script; one of : d, w, m.\n"; exit
     ;;
esac

# echo "The date of concern is: ${dateNEXT}"


# Path to License files
FILES="$2"
LICFILES=`find ${FILES:-/opt}  -name "*.lic" | xargs`
#
#
for FILE in $LICFILES; do                                                                                       # FOR-Loop-Start
  echo "File: $FILE"
  sFILE=`basename ${FILE%.lic}`                          # ; echo $sFILE
  qtyINCR=`egrep -c "INCR" ${FILE}`                      # ; echo "qtyINCR= ${qtyINCR}"
  ctr=0
  while [ $ctr -lt "${qtyINCR}" ]; do                                                                           # WHILE-Loop-Start
    # echo "counter= $ctr"
#
#   The lines following grab the data properly and populate into the array as we want!  Yay!
#
    eval mdl${sFILE}[$ctr]=$( awk '/INCR/ { print $2 }' ${FILE} | tail -"${qtyINCR}"  | head -$((  ctr + 1 )) | tail -1 )
    eval xpr${sFILE}[$ctr]=$( awk '/INCR/ { print $5 }' ${FILE} | tail -"${qtyINCR}"  | head -$((  ctr + 1 )) | tail -1 )
    cmdmdl='echo ${mdl'${sFILE}'['$(( $ctr ))']}'
    cmdxpr='echo ${xpr'${sFILE}'['$(( $ctr ))']}'
    cmdmdlprev='echo ${mdl'${sFILE}'['$(( $ctr - 1 ))']}'
    #
    # basic check
        echo "The last module was ${cmdmdlprev}."
    #
    #
    #
    if [ `eval ${cmdxpr}` == "permanent" ]; then
      echo -e "${fBLU}${bGRN}GOOD: No problems, the license `eval ${cmdmdl}` is permanent.${NORMAL}"
    elif [ "${dateNEXT}" -ge $( date -d `eval ${cmdxpr}` '+%s' ) ]; then
      echo -e "${fYLW}${bRED}EXPIRING: The module `eval ${cmdmdl}` will be expiring on `eval ${cmdxpr}`.${NORMAL}"
    else
      echo -e "${fWHT}${bBLU}The module `eval ${cmdmdl}` will _NOT BE_ expiring in a ${INTERVAL}.${NORMAL}"
    fi
    #
    #
    #
    ctr=$(( $ctr + 1 ))
  done                                                                                                          # WHILE-Loop-Finish
  sleep 2
  echo -e "\n\n\n"
done                                                                                                            # FOR-Loop-Finish
exit
