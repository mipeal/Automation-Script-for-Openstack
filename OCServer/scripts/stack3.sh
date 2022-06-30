local -i i n

mapfile password < /home/ubuntu/randompassword.txt
mapfile username < /home/ubuntu/randomusern.txt

if (( ${#password[@]} < ${#username[@]} )); then
  n=${#password[@]}
else
  n=${#username[@]}
fi

for (( i=0; i<n; i++ )); do
  u=${username[i]}
  p=${password[i]}$'\n'${password[i]}
#unqoute ($u)
  ocpasswd -c "/etc/ocserv/ocpasswd" $u <<< "$p"
done
