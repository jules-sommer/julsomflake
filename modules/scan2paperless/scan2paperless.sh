echo "$@"
DUPLEX=" Duplex"
removeempty="true"

[[ $1 == "-s" ]] && {
  DUPLEX=""
  removeempty=false
  shift
}

[[ $1 == "-a" ]] && {
  DUPLEX=" Duplex"
  removeempty="true"
  shift
}

[[ $1 == "-d" ]] && {
  DUPLEX=" Duplex"
  shift
}

pages=$1

cleanup() {
  img2pdf --pdfa --output /tmp/scan2paperless_$$.pdf /tmp/scan2paperless_$$_*.png && \
    rm -f /tmp/scan2paperless_$$_*.png
  post2paperless /tmp/scan2paperless_$$.pdf \
    && rm -f /tmp/scan2paperless_$$* \
    || echo "upload failed, retaining /tmp/scan2paperless_$$.pdf" >&2
}

trap 'cleanup; exit 1' EXIT

scanpage() {
  scanimage -d "$device" --source Flatbed -x 215.9 -y 297.011 --resolution 300 --format png
}

prependzeros() {
  printf "%03d" "$1"
}

flatbedscan() {
  cont=y
  i=0
  while [[ $cont = "y" ]]; do
    ((i+=1))
    scanpage > "/tmp/scan2paperless_$$_$(prependzeros ${i}).png"
    feh --scale-down "/tmp/scan2paperless_$$_$(prependzeros ${i}).png" &
    fehpid=$!
    if [[ -z $pages ]]; then
      echo "Scanned page $i. Append another page to the current document (Y/n)?"
      read -r input
      cont=${input:-y}
    else
      cont=y
      if [[ $pages -le $i ]]; then
        cont=n
      else
        echo "Press Enter to read page $((i+1))/$pages"
        read -r
      fi
    fi
    kill -0 "$fehpid" 2>/dev/null && kill "$fehpid"
  done
}

scanimage \
  -d "$device" \
  --format=png \
  --resolution 300 \
  --batch="/tmp/scan2paperless_$$_%d.png" \
  --batch-start=10 \
  --source="ADF${DUPLEX}" \
  -x 215.9 \
  -y 297.011

if $removeempty
then
  threshold=99
  images=( )
  values=( )
  for f in "/tmp/scan2paperless_$$_"*.png
  do
    images[${#images[@]}]=$f

    values[${#values[@]}]=$(convert "$f" -fuzz 02% -fill black +opaque white -fill white -opaque white -format "%[fx:100*mean]" info:)
  done

  for ((i=0;i<${#images[@]};i++))
  do
    if [[ $(echo "${values[i]} > $threshold" | bc -l) == "1" ]]
    then
      # bc will output 1 if the comparison is true, 0 otherwise
      echo image "${images[i]}" was found to be mostly white, removing.
      rm "${images[i]}"
    fi
  done
fi
