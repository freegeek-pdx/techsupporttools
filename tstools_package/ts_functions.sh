#!/bin/bash

# user functions

test_for_root(){
	if [[ $EUID -ne 0 ]]; then
		return 1
	else
		return 0
	fi
}

check_file_write(){
        file=$1
        touch $file 2>/dev/null
        return $?
}

choose_username(){
        declare -a user_list
        for file in /home/*; do
              if [[ -d $file ]]; then
                        name=$(echo $file | awk -F/ '{print $3}')
                        user_list=$user_list" $name"
                fi
        done

        PS3="Select a user "
        select user_name in $user_list; do
                break
        done
echo $user_name
}

test_for_uid(){
	local my_user=$1
	local my_uid=$(id -u $my_user)
	echo $my_uid
}

test_for_user(){
	local my_user=$1
	id $my_user &>/dev/null
	return $?
}

# password functions
reset_password(){
        local username=$1
        usermod --password zyrSQxJlOIQTo $username
	return $?
}

expire_password(){
	local username=$1
        passwd -e $username
        return $?
}

backup_passwords(){
	for file in passwd group shadow ; do
		if ! cp /etc/$file /etc/$file.fregeek_ts_backup.isotime;then
			failarray=( ${failarray[@]-} $(echo "$file") )
		fi
	done
	# check length of failarray if >0 then something failed
         if [[ ${#fail_array[@]} -ne 0 ]]; then
                echo -n "could not backup"
                for name in ${failarray[@]}; do
                        echo -n "/etc/$name"
                done
                return 3
        fi
}


# gconf related
set_gconf(){
	# checks to see if we are changing our own or somebody elses settings
	# --direct option can only be used if gconfd is not running as that 
	# users session
	local my_user=$1
        local my_uid=$(id -u $my_user)
	local setting=$2
	# test to see if self change and if gconfd-2 is running
	if [[ $my_uid -eq $EUID ]] && [[  $(pidof gconfd-2) ]]; then
        	gconftool-2 --recursive-unset $setting
	else
        	gconftool-2 --direct --config-source=xml::/home/$my_user/.gconf --recursive-unset $setting
	fi
	return $?
}


# write to error log and/or standard out 
write_msg(){
local msg="$1"
if [[ $2 ]]; then
        local logfile=$2
fi
echo "$msg"
if [[ $logfile ]]; then
        if ! echo "$msg" >>$logfile; then
        echo "Could not write to Log File: $logfile"
        exit 1
        fi
fi
}

