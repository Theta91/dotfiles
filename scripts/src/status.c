#define _XOPEN_SOURCE 700
#define _GNU_SOURCE 1
/* wireless */
#include <sys/socket.h>     /* must be before <linux/wireless.h> */
#include <sys/ioctl.h>
#include <linux/wireless.h>
#include <unistd.h>
/* fmt_date, obviously, and nanosleep */
#include <time.h>
/* fmod (battery) & pow (free_disk_space) */
#include <math.h>
/* free_disk_space */
#include <sys/statvfs.h>
#include <fcntl.h>
/* memory stuff */
#include <sys/sysinfo.h>
/* standard stuff */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#include "status.h"

double _battery_stats(const char *path);
static char _battery[_BAT_LEN], _cpu[_CPU_LEN], _date[_DATE_LEN], _iw[_IW_LEN],
            _mem[_MEM_LEN],_root[_FREE_LEN], _home[_FREE_LEN], _mail[_MAIL_LEN];

int main(void) {
    char *status = malloc(200);
    int b, m;
    b = BATTERY_INTERVAL;
    m = MAIL_INTERVAL;

    struct timespec interval = {
        .tv_sec  = UPDATE_INTERVAL,
        .tv_nsec = 0
    };
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    for( ; ; nanosleep(&interval, NULL)) {
        if(++b > BATTERY_INTERVAL) {
            battery();
            b = 0;
        }
        /*if(++m > MAIL_INTERVAL) {
            mail();
            m = 0;
        }*/
        if(sockfd != -1)
            wireless(sockfd);
        strncpy(_root, free_disk_space("/"), _FREE_LEN);
        strncpy(_home, free_disk_space("/home"), _FREE_LEN);
        fmt_date();
        cpu();
        memory();
        snprintf(status, 200, "%s %s | %s | %s | %s | %s | %s | %s", _root, _home, _iw, _battery, _mail, _cpu, _mem, _date);
        printf("%s\n", status);

//        break;
    }
    free(status);
    cleanup(sockfd);
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
    double full, now, uamps, hours, mins;

    if((fd = fopen(BAT_STATUS, "r")) == NULL) {
        status = 'X';
    }
    else {
        status = (char)fgetc(fd);
        fclose(fd);
    }

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

void cpu(void) {
    FILE *lfd, *tfd;
    static unsigned long ouser, onice, osystem, oidle;
    int work, total, temp;
    unsigned long user, nice, system, idle;

    if((lfd = fopen(LOAD_PATH, "r")) == NULL)
        return;
    fscanf(lfd, "cpu %lu %lu %lu %lu", &user, &nice, &system, &idle);
    work = (int)((user - ouser) + (nice - onice) + (system - osystem));
    total = (int)(work + (idle - oidle));

    ouser = user;
    onice = nice;
    osystem = system;
    oidle = idle;

    if((tfd = fopen(TEMP_PATH, "r")) == NULL)
        return;
    fscanf(tfd, "%d", &temp);

    snprintf(_cpu, _CPU_LEN, _CPU_FMT, 100 * work / total, temp / 1000);
}

void fmt_date(void) {
    time_t now = time(NULL);
    strftime(_date, _DATE_LEN, _DATE_FMT, localtime(&now));
}

char *free_disk_space(const char *path) {
    static struct statvfs vfs;
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

    snprintf(_free, _FREE_LEN, _FREE_FMT, path, free, unit[exp]);
    return _free;
}

void mail(void) {
    FILE *fp = popen("/home/voighta/bin/gmail.py", "r");
    int fd = fileno(fp);
    char *unread = NULL;
    size_t length = 3;
    ssize_t read;
    fcntl(fd, F_SETFL, O_NONBLOCK);

    if((read = getline(&unread, &length, fp)) == -1) {
        return;
    }
    else if(read > 0) {
        snprintf(_mail, _MAIL_LEN, _MAIL_FMT, unread);
    }
    else {
        free(unread);
        pclose(fp);
    }
}

void memory(void) {
    static struct sysinfo info;
    sysinfo(&info);
    snprintf(_mem, _MEM_LEN, _MEM_FMT, (int)(100 * info.freeram / info.totalram));
}

void wireless(int sockfd) {
    FILE *fd;
    char state[5];
    static char essid[ESSID_LEN];
    static int qual = 100;

    static struct iw_statistics wstats;
    static struct iwreq wreq = {
        .ifr_name = IW_NAME
    };

    if((fd = fopen(IW_PATH, "r")) == NULL)
        return;
    fscanf(fd, "%s", state);
    fclose(fd);
    if(strncmp(state, "up", 2) != 0)
        return;

    wreq.u.data.pointer = &wstats;
    wreq.u.data.length  = sizeof(wstats);
    qual = (ioctl(sockfd, SIOCGIWSTATS, &wreq) == -1) ?
        0 : (int)((float)(qual * 2 / 3) + (float)(100 * wstats.qual.qual / 210));

    wreq.u.data.pointer = &essid;
    wreq.u.data.length  = sizeof(essid);
    ioctl(sockfd, SIOCGIWESSID, &wreq);

    snprintf(_iw, _IW_LEN, _IW_FMT, qual, essid);
}

void cleanup(int sockfd) {
    if(sockfd != -1)
        close(sockfd);
}
