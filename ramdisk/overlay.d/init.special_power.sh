#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

# macro to write pids to system-background cpuset
function writepid_sbg() {
    until [ ! "$1" ]; do
        echo -n $1 > /dev/cpuset/system-background/tasks;
        shift;
    done;
}

################################################################################

{

sleep 10;

write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 748800;
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2169600;

write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq 0;
write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq 0;

#write /sys/module/cpu_input_boost/parameters/dynamic_stune_boost 20;

# Enable iowait boost to ramp up the CPU on repeated iowait wakeups
#write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable 1;
#write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/iowait_boost_enable 1;

#write /sys/module/cpu_boost/parameters/input_boost_freq "0:1056000 4:979200";
#write /sys/module/cpu_boost/parameters/input_boost_ms 1500;

# Setup ZRAM
#swapoff /dev/block/zram0;
#echo 1 > /sys/block/zram0/reset;
#echo 512M > /sys/block/zram0/disksize;
#mkswap /dev/block/zram0;
#swapon /dev/block/zram0;

# Set the default IRQ affinity to the silver cluster.
write /proc/irq/default_smp_affinity f

write /dev/stune/foreground/schedtune.prefer_idle 1
write /dev/stune/top-app/schedtune.prefer_idle 1

# Setup final cpuset
write /dev/cpuset/top-app/cpus 0-7
write /dev/cpuset/foreground/boost/cpus 0-3,6-7
write /dev/cpuset/foreground/cpus 0-3,6-7
write /dev/cpuset/background/cpus 0-1
write /dev/cpuset/system-background/cpus 0-3

# Runtime fs tuning: as we have init boottime setting and kernel patch setting
# default readahead to 2048KB. We should adjust the setting upon boot_complete
# for runtime performance
write /sys/block/sda/queue/read_ahead_kb 128
write /sys/block/sda/queue/nr_requests 128
write /sys/block/sda/queue/iostats 1
write /sys/block/sda/queue/scheduler cfq

write /sys/block/sde/queue/read_ahead_kb 128
write /sys/block/sde/queue/nr_requests 128
write /sys/block/sde/queue/iostats 1
write /sys/block/sde/queue/scheduler cfq

write /sys/block/sde/queue/read_ahead_kb 128
write /sys/block/sde/queue/nr_requests 128
write /sys/block/sde/queue/iostats 1
write /sys/block/sde/queue/scheduler cfq

write /sys/block/dm-0/queue/read_ahead_kb 128
write /sys/block/dm-0/queue/nr_requests 128
write /sys/block/dm-0/queue/iostats 1
write /sys/block/dm-0/queue/scheduler cfq

# Set up block I/O cgroups
write /dev/stune/blkio.group_idle 0
write /dev/stune/foreground/blkio.group_idle 1
write /dev/stune/background/blkio.group_idle 0
write /dev/stune/top-app/blkio.group_idle 2
write /dev/stune/rt/blkio.group_idle 2

write /dev/stune/blkio.weight 1000
write /dev/stune/foreground/blkio.weight 1000
write /dev/stune/background/blkio.weight 10
write > /dev/stune/top-app/blkio.weight 1000
write /dev/stune/rt/blkio.weight 1000

sleep 20;

QSEECOMD=`pidof qseecomd`
THERMAL-ENGINE=`pidof thermal-engine`
TIME_DAEMON=`pidof time_daemon`
IMSQMIDAEMON=`pidof imsqmidaemon`
IMSDATADAEMON=`pidof imsdatadaemon`
DASHD=`pidof dashd`
CND=`pidof cnd`
DPMD=`pidof dpmd`
RMT_STORAGE=`pidof rmt_storage`
TFTP_SERVER=`pidof tftp_server`
NETMGRD=`pidof netmgrd`
IPACM=`pidof ipacm`
QTI=`pidof qti`
LOC_LAUNCHER=`pidof loc_launcher`
QSEEPROXYDAEMON=`pidof qseeproxydaemon`
IFAADAEMON=`pidof ifaadaemon`
LOGCAT=`pidof logcat`
LMKD=`pidof lmkd`
PERFD=`pidof perfd`
IOP=`pidof iop`
MSM_IRQBALANCE=`pidof msm_irqbalance`
SEEMP_HEALTHD=`pidof seemp_healthd`
ESEPMDAEMON=`pidof esepmdaemon`
WPA_SUPPLICANT=`pidof wpa_supplicant`
SEEMPD=`pidof seempd`
EMBRYO=`pidof embryo`
HEALTHD=`pidof healthd`
OEMLOGKIT=`pidof oemlogkit`
NETD=`pidof netd`

writepid_sbg $QSEECOMD;
writepid_sbg $THERMAL-ENGINE;
writepid_sbg $TIME_DAEMON;
writepid_sbg $IMSQMIDAEMON;
writepid_sbg $IMSDATADAEMON;
writepid_sbg $DASHD;
writepid_sbg $CND;
writepid_sbg $DPMD;
writepid_sbg $RMT_STORAGE;
writepid_sbg $TFTP_SERVER;
writepid_sbg $NETMGRD;
writepid_sbg $IPACM;
writepid_sbg $QTI;
writepid_sbg $LOC_LAUNCHER;
writepid_sbg $QSEEPROXYDAEMON;
writepid_sbg $IFAADAEMON;
writepid_sbg $LOGCAT;
writepid_sbg $LMKD;
writepid_sbg $PERFD;
writepid_sbg $IOP;
writepid_sbg $MSM_IRQBALANCE;
writepid_sbg $SEEMP_HEALTHD;
writepid_sbg $ESEPMDAEMON;
writepid_sbg $WPA_SUPPLICANT;
writepid_sbg $SEEMPD;
writepid_sbg $HEALTHD;
writepid_sbg $OEMLOGKIT;
writepid_sbg $NETD;

}&
