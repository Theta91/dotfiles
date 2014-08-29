#define _XOPEN_SOURCE 500
#define _GNU_SOURCE

/* Wireless */
#include <sys/socket.h>     /* must be before <linux/wireless.h> */
#include <sys/ioctl.h>
#include <linux/wireless.h>
#include <unistd.h>

/* Date & sleep */
#include <time.h>

/* Battery */
#include <math.h>

/* Free disk space */
#include <sys/statvfs.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#include "status.h"

double _battery_stats(const char *path);
static char _battery[_BAT_LEN], _iw[_IW_LEN], _date[_DATE_LEN],
            _root[_FREE_LEN], _home[_FREE_LEN];
int main(void) {
    char *status;
    int m, n;
    m = _BATTERY_INTERVAL + 1;

    struct timespec interval = {
        .tv_sec  = _UPDATE_INTERVAL,
        .tv_nsec = 0
    };

    int sockfd;
    struct iw_statistics wstats;
    struct iwreq wreq = {
        .ifr_name = IW_NAME
    };
    if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) != -1){
        for( ; ; nanosleep(&interval, NULL)) {
            if(++m > _BATTERY_INTERVAL) {
                battery();
                m = 0;
            }
            wireless(sockfd, wreq, wstats);
            strncpy(_root, free_disk_space("/"), _FREE_LEN);
            strncpy(_home, free_disk_space("/home"), _FREE_LEN);
            fmt_date();
            snprintf(status, 200, "%s %s | %s | %s | %s", _root, _home, _iw, _battery, _date);
            printf("%s\n", status);

    //        break;
        }
    }

    cleanup(sockfd);

//sprintf("%s\n", *battery());
//strcat(&status[0],hrs,mins);
}

double _battery_stats(const char *path) {
    FILE *stats;
    double value = 0;

    if((stats = fopen(path, "r"))== NULL)
        return -1;

    fscanf(stats, "%lf", &value);
    fclose(stats);
    return value;
}

void battery(void) {
    FILE *fd;
    char status;
    double full, now, uamps,
           hours, mins;

    if((fd = fopen(BAT_STATUS, "r")) == NULL)
        status = 'X';
    status = (char)fgetc(fd);
    fclose(fd);

    if((status == 'C') || (status == 'D')) {
        now = _battery_stats(BAT_NOW);
        uamps = _battery_stats(BAT_CURRENT);

        if(status == 'C')
            full = _battery_stats(BAT_FULL);

        hours = (status == 'C') ? ((full - now) / uamps) : (now / uamps);
        mins = fmod(hours, 1) * 60;
    }

    switch(status) {
        case 'F': snprintf(_battery, _BAT_LEN, _BAT_FUL);
                  break;
        case 'C': snprintf(_battery, _BAT_LEN, _BAT_CRG, (int)hours, (int)mins);
                  break;
        case 'D': snprintf(_battery, _BAT_LEN, _BAT_DIS, (int)hours, (int)mins);
                  break;
        default:  snprintf(_battery, _BAT_LEN, _BAT_NON);
                  break;
    }
}

void fmt_date(void) {
    time_t now = time(NULL);
    setenv("TZ", "EST5EDT4", 1);

    tzset();
    strftime(_date, _DATE_LEN, _DATE_FMT, localtime(&now));
}

char *free_disk_space(const char *path) {
    struct statvfs vfs;
    static char _free[_FREE_LEN];
    static const char *unit[] = { "B", "K", "M", "G" };
    double free;
    int exp = 0;

    if(path[0] != '/')
        return "N/A";
    if(statvfs(path, &vfs) != 0)
        return "N/A";
    free = (double) vfs.f_frsize * vfs.f_bfree;

    exp = (int) log(free) / log(1024);
    free /= pow(1024, exp);

    snprintf(_free, _FREE_LEN, "%s: %.1lf%s", path, free, unit[exp]);
    return _free;
}

void wireless(int sockfd, struct iwreq wreq, struct iw_statistics wstats) {
    FILE *fd;
    char state[5];
    static char essid[ESSID_LEN];
    int qual;

    if((fd = fopen(IW_PATH, "r")) == NULL)
        return "N/A";
    fscanf(fd, "%s", state);
    fclose(fd);
    if(strncmp(state, "up", 2) != 0)
        return "N/A";

    wreq.u.data.pointer = &wstats;
    wreq.u.data.length  = sizeof(wstats);
    qual = (ioctl(sockfd, SIOCGIWSTATS, &wreq) == -1) ? 0 : (wstats.qual.qual * 100) / 70;

    wreq.u.data.pointer = &essid;
    wreq.u.data.length  = sizeof(essid);
    ioctl(sockfd, SIOCGIWESSID, &wreq);

    snprintf(_iw, _IW_LEN, "%d %s", qual, essid);
}

void cleanup(int sockfd) {
    if(sockfd != -1)
        close(sockfd);
}
