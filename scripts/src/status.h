/* Paths and such */
#define BAT_STATUS   "/sys/class/power_supply/BAT0/status"
#define BAT_FULL     "/sys/class/power_supply/BAT0/charge_full"
#define BAT_NOW      "/sys/class/power_supply/BAT0/charge_now"
#define BAT_CURRENT  "/sys/class/power_supply/BAT0/current_now"
#define IW_NAME      "wlo1"
#define IW_PATH      "/sys/class/net/wlo1/operstate"

/* Formats */
/* "%a %e %b '%y %T" = xxx xx xxx 'xx xx:xx:xx = 23 */
#define _DATE_FMT     "%a %e %b '%y %T"
#define _BAT_FUL      "F"
#define _BAT_CRG      "C: %1d:%02d"
#define _BAT_DIS      "D: %1d:%02d"
#define _BAT_NON      "N"

/* Update intervals (secs) */
#define _UPDATE_INTERVAL  1
#define _BATTERY_INTERVAL 5

/* String Lengths */
#define _BAT_LEN     17
#define _IW_LEN      37
#define _DATE_LEN    200
#define _FREE_LEN    40
#define ESSID_LEN    33
#define WEATHER_LEN  30

#define VOL_CH      "Master"
#define VOL_MUTE    "M %d%%"
#define VOL         "V %d%%"

/* Function Prototypes */
void battery(void);
void fmt_date(void);
char *free_disk_space(const char *path);
void wireless(int sockfd, struct iwreq wreq, struct iw_statistics wstats);
void cleanup(int sockfd);
