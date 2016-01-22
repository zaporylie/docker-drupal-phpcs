#!/bin/bash

parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

function join { local IFS="$1"; shift; echo "$*"; }

if [ ${DEBUG} = TRUE ]; then
	echo "PHP Code Sniffer"	
fi

# .phpcs.yml fallback
if [ ! -f ${PROJECT_ROOT}/.phpcs.yml ]; then
	if [ ${DEBUG} = TRUE ]; then
  	      echo "Missing phpcs config file, using default one"
	fi
	eval $(parse_yaml /tmp/.phpcs.yml "config_")
else
	eval $(parse_yaml ${PROJECT_ROOT}/.phpcs.yml "config_")

fi

# Enter project root
cd ${PROJECT_ROOT}
if [ ${DEBUG} = TRUE ]; then
        ls -la
fi

#
# Params.
#

PARAMS=""

# Standard.
if [ ! -z "${config_standard}" ]; then
	PARAMS="$PARAMS --standard=${config_standard}"
fi

# Extension.
if [ ! -z "${config_filter_extension}" ]; then
        PARAMS="$PARAMS --extensions=$(join , ${config_filter_extension[@]})"
fi

if [ ${DEBUG} = TRUE ]; then
        echo "Params: ${PARAMS}"
fi

# Folder
for i in "${!config_filter_folder[@]}"; do
	if [ -d "./${config_filter_folder[$i]}" ]; then
		if [ ${DEBUG} = TRUE ]; then
			echo "Running Code Snffer on: ${config_filter_folder[$i]}"
		fi
		$HOME/.composer/vendor/bin/phpcs$PARAMS  ${config_filter_folder[$i]}
		if [ $? -ne 0 ]; then
			ERROR=1
		fi
	else
		if [ ${DEBUG} = TRUE ]; then
                        echo "Missing directory: ${config_filter_folder[$i]}"
                fi
		unset config_filter_folder[$i]
	fi
done

if [ ! -z "${config_filter_folder}" ]; then
        echo "No folder found"
        exit 100;
fi

if [ ! -z "${ERROR}" ] && [ "${ERROR}" == "1" ]; then
	exit 1;
fi
