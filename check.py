"""
Check the status of each job in a sweep.
"""
for log in *${1}*/log.txt; do
    out=$(cat $log | tail -1)
    echo -e $out ' \t ' $log
done
