#
# Regular cron jobs for the vivid package
#
0 4	* * *	root	[ -x /usr/bin/vivid_maintenance ] && /usr/bin/vivid_maintenance
