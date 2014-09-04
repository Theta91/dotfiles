/* Paths and such */
#define BAT_STATUS   "/sys/class/power_supply/BAT0/status"
#define BAT_FULL     "/sys/class/power_supply/BAT0/charge_full"
#define BAT_NOW      "/sys/class/power_supply/BAT0/charge_now"
#define BAT_CURRENT  "/sys/class/power_supply/BAT0/current_now"
#define IW_NAME      "wlo1"
#define IW_PATH      "/sys/class/net/wlo1/operstate"
#define LOAD_PATH    "/proc/stat"
#define TEMP_PATH    "/sys/devices/virtual/thermal/thermal_zone0/temp"

/* Formats */
/* "%a %e %b '%y %T" = xxx xx xxx 'xx xx:xx:xx = 23 */
#define _BAT_CRG      "C %1d:%02d"
#define _BAT_DIS      "D %1d:%02d"
#define _BAT_FUL      "F"
#define _BAT_NON      "N"
#define _CPU_FMT      "CPU %3d%% %2dC"
#define _DATE_FMT     "%a %e %b %T"
#define _FREE_FMT     "%s %.1lf%s"
#define _MAIL_FMT     "NEW %s"
#define _IW_FMT       "%3d %s"
#define _MEM_FMT      "MEM %2d%%"

/* Update intervals (secs) */
#define UPDATE_INTERVAL   1
#define BATTERY_INTERVAL  5
#define MAIL_INTERVAL    10

/* String Lengths */
#define _BAT_LEN     17
#define _CPU_LEN     13
#define _DATE_LEN    24
#define _FREE_LEN    15
#define _MAIL_LEN    10
#define _IW_LEN      37
#define _MEM_LEN      8
#define ESSID_LEN    33
#define WEATHER_LEN  30

#define VOL_CH      "Master"
#define VOL_MUTE    "M %d%%"
#define VOL         "V %d%%"

/* Function Prototypes */
void battery(void);
void cpu(void);
void fmt_date(void);
char *free_disk_space(const char *path);
void mail(void);
void memory(void);
void wireless(int sockfd);//int sockfd, struct iwreq wreq, struct iw_statistics wstats);
void cleanup(int sockfd);
