#
# Regular cron jobs for the kubectx package
#
0 4	* * *	root	[ -x /usr/bin/kubectx_maintenance ] && /usr/bin/kubectx_maintenance
