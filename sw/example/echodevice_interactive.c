#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <pthread.h>
#include <time.h>

#define BUFFER_SIZE 1024
#define DMA_CHANNEL_COUNT 16

int main (int argc, char **argv) {
    if (argc < 2) {
        return -1;
    }

    int channel = atoi(argv[1]);

    if (channel >= DMA_CHANNEL_COUNT) {
        printf("Channel should be from %d to %d, received %d\n", 0, DMA_CHANNEL_COUNT-1, channel);
    }

    int dma_fd;

    char *filepath;

    int size = asprintf(&filepath, "/dev/hdlnocgen_c5p%d", channel);
    if (size < 0) {
        return size;
    }

    dma_fd = open(filepath, O_RDWR);
    free(filepath);
    if (dma_fd < 0) {
        return dma_fd;
    }


    char input_str[BUFFER_SIZE];
    char dma_read[BUFFER_SIZE];

    printf("DMA channel %d echodevice demonstration. Write something: ", channel);
    if (!fgets(input_str, sizeof(input_str), stdin)) {
        printf("Failed to read the string\n"); 
        close(dma_fd);
        return -2;
    }

    printf("You entered %s\n", input_str);

    printf("Resetting the DMA controller...\n");
    int csr_fd = open("/dev/hdlnocgen_c5p_dma_csr", O_RDWR);
    if (csr_fd < 0) {
        return csr_fd;
    }
    uint32_t writedata = 0;
    pwrite(csr_fd, &writedata, 4, (off_t)0xC);
    printf("DMA controller is reset\n");

    printf("Writing to DMA channel %d... ", channel);
    write(dma_fd, input_str, sizeof(input_str));
    printf("Done\n");
    printf("Reading from DMA channel %d... ", channel);
    read(dma_fd, dma_read, sizeof(dma_read));
    printf("Done\n");

    printf("DMA says: %s\n", dma_read);

    // Trashing DMA channels
    /*
    printf("Trashing DMA task queue...\n");
    for (int i = 0; i < 8; i++) {
        read(dma_fd, dma_read, sizeof(dma_read));
    }
    printf("Trashing DMA task queue trashed\n");
    */

    close(csr_fd);
    close(dma_fd);
}
