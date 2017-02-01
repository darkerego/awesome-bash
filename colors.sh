#!/bin/bash

format(){
echo '-----------------------------------------------'
echo -e 'Syntax:\n'
echo -e "this: '\\\e[31m' == \e[31m _RED_ \e[0m\nthis: '\\\e[0m' == RESETS All Formating"
echo '-----------------------------------------------'
echo -e 'Examples:\n'
printf 'echo -e \"this: \'\\e[95m;printf " == \e[95m _PINK_ \e[0m\"";echo
echo -n 'printf "\e[34m"';echo -e "\e[34m _BLUE_ \e[0m"
echo -e '-----------------------------------------------'
echo
}

background(){
for fgbg in 38 48 ; do #Foreground/Background
        for color in {0..256} ; do #Colors
                #Display the color
                echo -en "\e[${fgbg};5;${color}m ${color}\t\e[0m"
                #Display 10 colors per lines
                if [ $((($color + 1) % 10)) == 0 ] ; then
                        echo #New line
                fi
        done
        echo #New line
done


}

foreground(){
for clbg in {40..47} {100..107} 49 ; do
        #Foreground
        for clfg in {30..37} {90..97} 39 ; do
                #Formatting
                for attr in 0 1 2 4 5 7 ; do
                        #Print the result
                        echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
                done
                echo #Newline
        done
done

}

case "$@" in --fg|-f)
echo 'Foreground Colors:'
foreground
format
;;

--bg|-b)
echo 'Background colors:'
background
format
echo
;;

-h|--help)
echo -e "USAGE: \e[33mc\e[32mo\e[31ml\e[36mo\e[33mr\e[34ms\e[0m [-b/--bg][-f/--fg]\e[0m"
format
;;

*)
echo 'FG Colors:'
foreground
echo 'BG Colors:'
background
echo 'Format: echo -e "echo -e "\e[31mThis is Red\e[0m This Reset Format"'
format
;;
esac

exit
