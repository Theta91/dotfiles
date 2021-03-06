/* A somewhat well-commented example of using ioctl to grab ESSID and quality
 * of wireless connection. Much more is possible: read <linux/wireless.h>. */

#include <sys/ioctl.h>       /* technically, not needed */
#include <sys/socket.h>      /* must be before <linux/wireless.h> */
#include <linux/wireless.h>

#include <stdio.h>
#include <string.h>

#define IWNAME "wlo1"

int main(void) {
    int sockfd;
    /* wstats will contain wireless statistics: quality, packets discarded/missed */
    struct iw_statistics wstats;
    /* wreq contains the union 'u.data'. We'll set its .pointer & .length anew
     * for every ioctl call. */
    struct iwreq wreq = { .ifr_name = IWNAME };

    /* AF_INET - IP domain/address family. SOCK_DGRAM - datagram socket */
    if((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("Error getting socket");
        return -1; }

    /* SIOCGIWSTATS:
     * .qual.qual - link quality
     * .qual.level - signal level (dBm)
     * .qual.noise - noise level (dBm)
     * .qual.updated - bitmasks. important: IW_QUAL_DBM, IW_QUAL_*_UPDATED */
    wreq.u.data.pointer = &wstats;
    wreq.u.data.length  = sizeof(wstats);
    if(ioctl(sock, SIOCGIWSTATS, &wreq) == -1) {
        perror("Error getting stats");
        return -1; }

    /* SIOCGIWESSID can be up to 32 bytes long. */
    char essid[33];
    memset(essid, 0, 33);
    wreq.u.data.pointer = &essid;
    wreq.u.data.length  = sizeof(essid);
    if(ioctl(sock, SIOCGIWESSID, &wreq) == -1) {
        perror("Error getting ESSID");
        return -1; }

    /* max quality on my machine is 70 -- set that to 100 */
    printf("{ 'quality': '%d', 'essid': '%s' }\n", 100 * wstats.qual.qual / 70, essid);

    close(sockfd);
    return 0; }
