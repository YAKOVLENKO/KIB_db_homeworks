#!/bin/bash


COFFEESHOP_PATH=~/davecoffeeshop.db
####################
# welcome info
cat <<- _WELCOME_
Welcome to the Dave Coffeeshop!

USAGE:
To log order, enter LOG
To end session, enter EOS
To end business day, enter EOD

Log is placed here: "$COFFEESHOP_PATH"

_WELCOME_
####################


# get price for coffee name
get_price() {
if [ "$1" == 'AME' ]; then 
	echo '100'
elif [ "$1" == 'ESP' ]; then
	echo '120'
elif [ "$1" == 'CAP' ]; then 
	echo '150'
elif [ "$1" == 'LAT' ]; then 
	echo '170'
elif [ "$1" == 'RAF' ]; then 
	echo '200'
else 
	echo ERROR
fi
}


#  check if COFFEESHOP_PATH file exists
check_log_existance() {
if ! [ -e $COFFEESHOP_PATH ]; then
	touch $COFFEESHOP_PATH
fi 
}


#  write barista name, drink name, and price value to database
write_to_db() {
echo "$1;$2;$3" >> $COFFEESHOP_PATH
}


#  function for LOG command
command_LOG() {

read -p 'Barista name: ' barista_name
read -p 'Drinking: ' drink_name
price_val=$(get_price $drink_name)

if [ $price_val == 'ERROR' ] || ! [[ "$barista_name" =~ [a-zA-Z0-9_.]+ ]] || ! [ "${BASH_REMATCH[0]}" == "$barista_name" ]; then
	echo 'Wrong input data! Try again.'
else 
	write_to_db "$barista_name" "$drink_name" "$price_val" 
fi
}


# function for finding index of barista in list
# 1st arg - list
# 2nd arg - barista name
find_barista() {
local result=-1
local index=0
for barista in ${list_of_barista[@]};
do
	if [ "$1" == $barista ]; then
		result=$index
		break
	fi
	index=$(($index+1))
done
echo $result
}


find_biggest_i() {
        local max_val=0
        local max_index=0
        local index=0
        for summ in ${list_of_money[@]}; do
                if (( $max_val < $summ )) ; then
                        max_val=$summ
                        max_index=$index
                fi
                ((++index))
        done
        echo $max_index
}


#  function for EOD command
command_EOD() {
list_of_barista=()
list_of_money=()
echo 'Results of the day:'
while IFS=';' read person drink price; do
	local barista_index=$(find_barista "$person")
	if [ "$barista_index"  == '-1' ]; then
		list_of_barista+=("$person")
		list_of_money+=("$price")
	else 
		list_of_money["$barista_index"]=$((list_of_money["$barista_index"]+"$price"))
	fi
done < "$COFFEESHOP_PATH"

while ! [ ${#list_of_barista[@]} == 0 ]; do
        local curr_index=$(find_biggest_i)
        echo "${list_of_barista[$curr_index]};${list_of_money[$curr_index]}"
        list_of_barista=( "${list_of_barista[@]:0:$curr_index}" "${list_of_barista[@]:(($curr_index+1))}" )
        list_of_money=( "${list_of_money[@]:0:$curr_index}" "${list_of_money[@]:(($curr_index+1))}" )
done

}


#  start of main part
check_log_existance
while true; do
	echo ''
	read -p 'Command: ' curr_command
	if [ "$curr_command" == 'LOG' ]; then
		command_LOG
	elif [ "$curr_command" == 'EOS' ]; then 
		exit
	elif [ "$curr_command" == 'EOD' ]; then
		command_EOD
	fi
done


