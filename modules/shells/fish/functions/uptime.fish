argparse -n pretty-uptime s/short m/medium l/long G/no-glyph -- $argv
set -l mode short
if set -q _flag_medium
    set mode medium
end
if set -q _flag_long
    set mode long
end

set -l upsecs
if test -r /proc/uptime
    set upsecs (math -s0 (string split ' ' (cat /proc/uptime))[1])
else if command -q sysctl
    set -l bt (sysctl -n kern.boottime 2>/dev/null | string replace -r '.*sec = ([0-9]+).*' '$1')
    if test -n "$bt"
        set upsecs (math (date +%s) - $bt)
    end
end
if test -z "$upsecs"
    set -l txt (uptime)
    set -l after (string split -m1 ' up ' $txt)[2]
    set -l field (string split -m1 ',  ' $after)[1]
    set -l d 0
    set -l h 0
    set -l m 0
    if string match -rq '([0-9]+) day' -- $field
        set d (string replace -r '.*?([0-9]+) day.*' '$1' $field)
        set field (string replace -r '([0-9]+) days?,? ?' '' $field)
    end
    if string match -rq '([0-9]+):([0-9]+)' -- $field
        set h (string replace -r '.*?([0-9]+):([0-9]+).*' '$1' $field)
        set m (string replace -r '.*?([0-9]+):([0-9]+).*' '$2' $field)
    else if string match -rq '([0-9]+) min' -- $field
        set m (string replace -r '.*?([0-9]+) min.*' '$1' $field)
    else if string match -rq '([0-9]+) hr' -- $field
        set h (string replace -r '.*?([0-9]+) hr.*' '$1' $field)
    end
    set upsecs (math $d \* 86400 + $h \* 3600 + $m \* 60)
end

set -l days (math -s0 "$upsecs / 86400")
set -l rem (math "$upsecs % 86400")
set -l hours (math -s0 "$rem / 3600")
set rem (math "$rem % 3600")
set -l mins (math -s0 "$rem / 60")

set -l parts
if test $days -gt 0
    switch $mode
        case short
            set parts $parts "$days"d
        case medium
            set parts $parts "$days days"
        case long
            if test $days -eq 1
                set parts $parts "1 day"
            else
                set parts $parts "$days days"
            end
    end
end
if test $hours -gt 0
    switch $mode
        case short
            set parts $parts "$hours"h
        case medium
            if test $hours -eq 1
                set parts $parts "1 hr"
            else
                set parts $parts "$hours hrs"
            end
        case long
            if test $hours -eq 1
                set parts $parts "1 hour"
            else
                set parts $parts "$hours hours"
            end
    end
end
if test $mins -gt 0 -o \( $days -eq 0 -a $hours -eq 0 \)
    switch $mode
        case short
            set parts $parts "$mins"m
        case medium
            if test $mins -eq 1
                set parts $parts "1 min"
            else
                set parts $parts "$mins mins"
            end
        case long
            if test $mins -eq 1
                set parts $parts "1 minute"
            else
                set parts $parts "$mins minutes"
            end
    end
end

set -l glyph ""
if set -q _flag_no_glyph
    set glyph ""
end

set -l out (string join ' ' $parts)
if test -n "$glyph"
    printf "%s%s\n" $glyph $out
else
    printf "%s\n" $out
end
