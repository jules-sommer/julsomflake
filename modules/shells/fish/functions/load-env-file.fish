set -l file (string trim $argv[1])
if test -z "$file"
    set file .env # Default to ".env" if no argument is provided
end

if not test -e $file
    return
end

while read -la line
    if not string match -q "#*" $line
        set -l key (string trim (string split -m1 "=" $line)[1])
        set -l value (string trim (string split -m1 "=" $line)[2..])
        if test -n "$key"
            echo "Exporting global variable `$key=$value`"
            set -xg $key (string join "=" $value | string trim)
        end
    end
end <$file
