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
#define _BAT_CRG      "C %1d:%02d"     /* 7 */
#define _BAT_DIS      "D %1d:%02d"
#define _BAT_FUL      "F"
#define _BAT_NON      "N"
#define _CPU_FMT      "CPU %3d%% %2dC" /* 13 */
#define _DATE_FMT     "%a %e %b %H:%M" /* 17 */
#define _FREE_FMT     "%s %.1lf%s"     /*    */
#define _MAIL_FMT     "NEW %2s"        /*  7 */
#define _IW_FMT       "NET %s"         /* 37 */
#define _MEM_FMT      "MEM %2d%%"      /*  8 */

/* Update intervals (secs) */
#define UPDATE_INTERVAL    1
#define BATTERY_INTERVAL   5
#define MAIL_INTERVAL    300
#define DATE_INTERVAL     50

/* String lengths */
#define _BAT_LEN      7
#define _CPU_LEN     13
#define _DATE_LEN    17
#define _FREE_LEN    15
#define _MAIL_LEN     7
#define _IW_LEN      37
#define _MEM_LEN      8
#define ESSID_LEN    33
#define WEATHER_LEN  30

#define VOL_CH      "Master"
#define VOL_MUTE    "M %d%%"
#define VOL         "V %d%%"

/* Function prototypes */
void print_battery(void);
void print_cpu(void);
void print_time(void);
char *print_free(const char *path);
ssize_t print_mail(FILE *fp);
void print_memory(void);
void print_iw(int sockfd);
void cleanup(int sockfd);
