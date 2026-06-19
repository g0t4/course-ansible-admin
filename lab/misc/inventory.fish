#!/usr/bin/env fish

# ping pi1 to pi10 and echo out the resulting list in an ansible inventory compatible format
for i in (seq 1 10)
    set host pi$i
    if ping -c 1 -W 1 $host > /dev/null 2>&1
        # collect hosts
        set -a hosts $host
        # build hostvars entry
        set host_entry (printf '{"ansible_host":"%s","ansible_user":"pi"}' $host)
        set -a hostvars "\"$host\": $host_entry"
    end
end

# join arrays into JSON fragments
# Quote each host and join them with commas
set hosts_json (string join ',' (for host in $hosts; echo "\"$host\""; end))

set hostvars_json (string join ',' $hostvars)

# output JSON for Ansible script inventory plugin
echo "{"
echo "  \"raspberries\": {"
echo "    \"hosts\": [$hosts_json],"
echo "    \"vars\": {}"
echo "  },"
echo "  \"_meta\": {"
echo "    \"hostvars\": {$hostvars_json}"
echo "  }"
echo "}"

