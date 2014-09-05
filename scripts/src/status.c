#define _XOPEN_SOURCE 500
#define _GNU_SOURCE

#include <math.h>           /* print_battery() + print_free() */
#include <sys/statvfs.h>    /* print_free() */
#include <sys/ioctl.h>      /* print_iw() */
#include <sys/socket.h>
#include <linux/wireless.h>
#include <unistd.h>
#include <fcntl.h>          /* print_mail() */
#include <errno.h>
#include <sys/sysinfo.h>    /* print_memory() */
#include <time.h>           /* print_time() + nanosleep */

#include <stdlib.h>         /* standard stuff */
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#include "status.h"

FILE *mail_init(void);
double get_battery_stats(const char *path);
static char _battery[_BAT_LEN], _cpu[_CPU_LEN], _date[_DATE_LEN], _iw[_IW_LEN],
            _mem[_MEM_LEN],_root[_FREE_LEN], _home[_FREE_LEN], _mail[_MAIL_LEN];

int main(void) {
    FILE *fp_mail;
    char *status = (char *)alloca(200);
    int b, d, m;
    b = BATTERY_INTERVAL;
    d = DATE_INTERVAL;
    m = MAIL_INTERVAL;

    struct timespec interval = {
        .tv_sec  = UPDATE_INTERVAL,
        .tv_nsec = 0 };
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    for ( ; ; nanosleep(&interval, NULL)) {
        if (++b > BATTERY_INTERVAL) {
            print_battery();
            b = 0; }
        if (++d > DATE_INTERVAL) {
            print_time();
            d = 0; }
        if (++m > MAIL_INTERVAL) {
            if (print_mail(fp_mail) == 0) {
                m = 0; }
            if (errno == EBADF) {
                fp_mail = mail_init(); } }
        if (sockfd != -1) {
            print_iw(sockfd); }
        strncpy(_root, print_free("/"), _FREE_LEN);
        strncpy(_home, print_free("/home"), _FREE_LEN);
        print_time();
        print_cpu();
        print_memory();
        snprintf(status, 200, "%s %s | %s | %s | %s | %s | %s | %s"
                            , _root, _home, _iw, _battery, _mail, _cpu
                            , _mem, _date);
        printf("%s\n", status);

        }//break; }

    pclose(fp_mail);
    cleanup(sockfd); }

double get_battery_stats(const char *path) {
    FILE *stats;
    double value = 0;

    if ((stats = fopen(path, "r"))== NULL) {
        return -1; }
    fscanf(stats, "%lf", &value);
    fclose(stats);

    return value; }

void print_battery(void) {
    FILE *fd;
    char status;
    float full, now, uamps, hours, mins;

    if ((fd = fopen(BAT_STATUS, "r")) == NULL) {
        status = 'X'; }
    else {
        status = (char)fgetc(fd);
        fclose(fd); }

    if ((status == 'C') || (status == 'D')) {
        now = get_battery_stats(BAT_NOW);
        uamps = get_battery_stats(BAT_CURRENT);

        if(status == 'C') {
            full = get_battery_stats(BAT_FULL); }

        hours = (status == 'C') ? ((full - now) / uamps) : (now / uamps);
        mins = fmod(hours, 1.0) * 60.0; }

    switch (status) {
        case 'F': snprintf(_battery, _BAT_LEN, _BAT_FUL);
                  break;
        case 'C': snprintf(_battery, _BAT_LEN, _BAT_CRG, (int)hours, (int)mins);
                  break;
        case 'D': snprintf(_battery, _BAT_LEN, _BAT_DIS, (int)hours, (int)mins);
                  break;
        default:  snprintf(_battery, _BAT_LEN, _BAT_NON); } }

void print_cpu(void) {
    FILE *fd_load, *fd_temp;
    static unsigned long jiffies_total[2], jiffies_work[2];
    unsigned long j, work, total;
    int i, temp;

    if ((fd_load = fopen(LOAD_PATH, "r")) == NULL) {
        return; }
    if ((fd_temp = fopen(TEMP_PATH, "r")) == NULL) {
        return; }

    fscanf(fd_load, "cpu %lu", &jiffies_total[1]);
    for (i = 2; i <= 7; i++) {
        fscanf(fd_load, "%lu", &j);
        jiffies_total[1] += j;
        if (i == 3) {
            jiffies_work[1] = jiffies_total[1]; } }
    fclose(fd_load);

    fscanf(fd_temp, "%d", &temp);
    fclose(fd_temp);

    work = jiffies_work[1] - jiffies_work[0];
    total = jiffies_total[1] - jiffies_total[0];

    snprintf(_cpu, _CPU_LEN, _CPU_FMT, 100 * work / total, temp / 1000);

    memmove(&jiffies_work[0], &jiffies_work[1], sizeof(jiffies_work[1]));
    memmove(&jiffies_total[0], &jiffies_total[1], sizeof(jiffies_total[1])); }

char *print_free(const char *path) {
    static struct statvfs vfs;
    static char _free[_FREE_LEN];
    static const char *unit[] = { "B", "K", "M", "G", "T" };
    float free;
    int exp = 0;

    if (path[0] != '/') {
        return "N/A"; }
    if (statvfs(path, &vfs) != 0) {
        return "N/A"; }
    free = (float) vfs.f_frsize * vfs.f_bfree;

    exp = (int) log(free) / log(1024);
    free /= pow(1024, exp);

    snprintf(_free, _FREE_LEN, _FREE_FMT, path, free, unit[exp]);
    return _free; }

void print_iw(int sockfd) {
    FILE *fd;
    char state[5];
    static char essid[ESSID_LEN];
    static int qual = 100;

    static struct iw_statistics wstats;
    static struct iwreq wreq = { .ifr_name = IW_NAME };

    if ((fd = fopen(IW_PATH, "r")) == NULL) {
        return; }
    fscanf(fd, "%s", state);
    fclose(fd);
    if (strncmp(state, "up", 2) != 0) {
        return; }

    wreq.u.data.pointer = &wstats;
    wreq.u.data.length  = sizeof(wstats);
    qual = (ioctl(sockfd, SIOCGIWSTATS, &wreq) == -1) ?
        0 : (int)((float)(qual * 2 / 3) + (float)(100 * wstats.qual.qual / 210));

    wreq.u.data.pointer = &essid;
    wreq.u.data.length  = sizeof(essid);
    ioctl(sockfd, SIOCGIWESSID, &wreq);

    snprintf(_iw, _IW_LEN, _IW_FMT, state); }

FILE *mail_init(void) {
    FILE *fp = popen("/home/voighta/bin/gmail.sh", "r");
    int fd = fileno(fp);
    fcntl(fd, F_SETFL, O_NONBLOCK);

    return fp; }

ssize_t print_mail(FILE *fp) {
    int fd = fileno(fp);
    size_t length = 2;
    ssize_t size_read;
    char *unread = (char *)alloca(length + 1);
    memset(unread, '\0', sizeof(char) * (length + 1));

    size_read = read(fd, unread, length);
    if (size_read > 0) {
        snprintf(_mail, _MAIL_LEN, _MAIL_FMT, unread); }
    if (size_read == 0) {
        pclose(fp); }

    return size_read; }

void print_memory(void) {
    static struct sysinfo info;
    sysinfo(&info);
    snprintf(_mem, _MEM_LEN, _MEM_FMT, (int)(100 * info.freeram / info.totalram)); }

void print_time(void) {
    time_t now = time(NULL);
    strftime(_date, _DATE_LEN, _DATE_FMT, localtime(&now)); }

void cleanup(int sockfd) {
    if (sockfd != -1) {
        close(sockfd); } }
