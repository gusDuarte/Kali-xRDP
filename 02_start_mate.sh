# Define necessary environment variables
export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'):0.0"
# Start desktop environment
mate-session