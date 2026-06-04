#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <pthread.h>
#include <time.h>

#define ARRAY_SIZE (uint64_t)(1024*16/8)
#define DMA_CHANNEL_COUNT 8
#define TASK_MULTIPLIER 128

uint64_t kal[DMA_CHANNEL_COUNT][TASK_MULTIPLIER][ARRAY_SIZE];
uint64_t checker[DMA_CHANNEL_COUNT][TASK_MULTIPLIER][ARRAY_SIZE];
int fd[DMA_CHANNEL_COUNT];
int fail[DMA_CHANNEL_COUNT];

pthread_t subthreads[DMA_CHANNEL_COUNT][TASK_MULTIPLIER*2];

void *dma_read (void *index) {
    uint64_t index_int = (uint64_t)index;
    printf("Read %lx, %lx\n", index_int & 0xFFFFFFFF, index_int >> 32);
    read(fd[index_int & 0xFFFFFFFF],
        checker[index_int & 0xFFFFFFFF][index_int >> 32],
        sizeof(checker[index_int & 0xFFFFFFFF][index_int >> 32]));
}
void *dma_write (void *index) {
    uint64_t index_int = (uint64_t)index;
    printf("Write %lx, %lx\n", index_int & 0xFFFFFFFF, index_int >> 32);
    write(fd[index_int & 0xFFFFFFFF],
        kal[index_int & 0xFFFFFFFF][index_int >> 32],
        sizeof(kal[index_int & 0xFFFFFFFF][index_int >> 32]));
}

void *trash (void *index) {
    for (int i = 0; i < TASK_MULTIPLIER; i++) {
        pthread_create(&subthreads[0][i*2], NULL, dma_read, (void *)(uint64_t)(i % DMA_CHANNEL_COUNT));
        pthread_create(&subthreads[0][i*2+1], NULL, dma_write, (void *)(uint64_t)(i % DMA_CHANNEL_COUNT));
    }
    for (int i = 0; i < TASK_MULTIPLIER; i++) {
        pthread_join(subthreads[0][i*2], NULL);
        pthread_join(subthreads[0][i*2+1], NULL);
    }

}

int main () {

    pthread_t threads[DMA_CHANNEL_COUNT];

    struct timespec start, stop;
    double elapsed = 0;


    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        char *filepath;

        int size = asprintf(&filepath, "/dev/hdlnocgen_c5p%d", i);
        if (size < 0) {
            return size;
        }

        fd[i] = open(filepath, O_RDWR);
        free(filepath);
        if (fd[i] < 0) {
            for (int j = 0; j < i; j++) {
                close(fd[j]);
            }
            return fd[i];
        }
    }
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        fail[i] = 0;
    }


    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        for (int j = 0; j < TASK_MULTIPLIER; j++) {
            for (int k = 0; k < ARRAY_SIZE; k++) {
                kal[i][j][k] = i * DMA_CHANNEL_COUNT + j * TASK_MULTIPLIER + k;
                checker[i][j][k] = 0;
            }
        }
    }
    printf("All channels initialized data\n");

    int csr_fd = open("/dev/hdlnocgen_c5p_dma_csr", O_RDWR);
    if (csr_fd < 0) {
        return csr_fd;
    }
    uint32_t writedata = 0;
    uint32_t readdata;
    pwrite(csr_fd, &writedata, 4, (off_t)0xC);
    do {
        pread(csr_fd, &readdata, 4, (off_t)0xC);
    } while (readdata != 0x1);
    printf("DMA controller reset\n");

    clock_gettime(CLOCK_MONOTONIC, &start);
    pthread_create(&threads[0], NULL, trash, NULL);
    pthread_join(threads[0], NULL);
    clock_gettime(CLOCK_MONOTONIC, &stop);

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        for (int j = 0; j < TASK_MULTIPLIER; j++) {
            for (int k = 0; k < ARRAY_SIZE; k++) {
                if (kal[i][j][k] != checker[i][j][k]) {
                    fail[i]++;
                }
            }
        }
    }

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        for (int j = 0; j < TASK_MULTIPLIER; j++) {
            for (int k = 0; k < ARRAY_SIZE; k++) {
                checker[i][j][k] = 0;
            }
        }
    }

    elapsed += (stop.tv_sec*1e9 + stop.tv_nsec) - (start.tv_sec*1e9 + start.tv_nsec);

    printf("All channels read from dma\n");

    printf("Fail array: ");
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        printf("%d ", fail[i]);
    }
    printf("\n");
}
