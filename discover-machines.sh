#!/bin/bash
# Auto-discover machines on the network using mDNS

MACHINES=("brain.local" "pinky.local" "max.local")

echo "{"
echo "  \"discovered\": ["

first=true
for machine in "${MACHINES[@]}"; do
  # Try to resolve the hostname
  ip=$(ping -c 1 -W 1 "$machine" 2>/dev/null | grep "PING" | awk '{print $3}' | tr -d '()')

  if [ -n "$ip" ]; then
    if [ "$first" = false ]; then
      echo ","
    fi
    first=false

    echo "    {"
    echo "      \"hostname\": \"$machine\","
    echo "      \"ip\": \"$ip\","
    echo "      \"reachable\": true"
    echo -n "    }"
  fi
done

echo ""
echo "  ],"
echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\""
echo "}"
