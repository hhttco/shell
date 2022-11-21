#!/bin/bash

panelConfig() {
  echo $1
  echo $2
}


main () {
  panelConfig $@
	# show_status $@
	# echo -e "$?"
	# if [[ $? == 1 ]]; then
 #        echo -e "是否开机自启: $?"
 #    else
 #        echo -e "==== $?"
 #    fi
}

main $@
