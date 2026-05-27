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

uint64_t kal[DMA_CHANNEL_COUNT][ARRAY_SIZE];
uint64_t checker[DMA_CHANNEL_COUNT][ARRAY_SIZE];
int fd[DMA_CHANNEL_COUNT];
int fail[DMA_CHANNEL_COUNT];

pthread_t dma_read_threads[DMA_CHANNEL_COUNT];
pthread_t dma_write_threads[DMA_CHANNEL_COUNT];

void *dma_read (void *index) {
    int index_int = (uint64_t)index;
    read(fd[index_int], checker[index_int], sizeof(checker[index_int]));
}
void *dma_write (void *index) {
    int index_int = (uint64_t)index;
    write(fd[index_int], kal[index_int], sizeof(kal[index_int]));
}

void *dma_read_thread (void *index) {
    int index_int = (uint64_t)index;
    for (int i = index_int; i < DMA_CHANNEL_COUNT; i += 2) {
        pthread_create(&dma_read_threads[i], NULL, dma_read, (void *)(uint64_t)i);
    }

    for (int i = index_int; i < DMA_CHANNEL_COUNT; i += 2) {
        pthread_join(dma_read_threads[i], NULL);
    }
}

void *dma_write_thread (void *index) {
    int index_int = (uint64_t)index;
    for (int i = index_int; i < DMA_CHANNEL_COUNT; i += 2) {
        pthread_create(&dma_write_threads[i], NULL, dma_write, (void *)(uint64_t)i);
    }

    for (int i = index_int; i < DMA_CHANNEL_COUNT; i += 2) {
        pthread_join(dma_write_threads[i], NULL);
    }
}

int main (int argc, char **argv) {
    if (argc < 2) {
        return -1;
    }

    int iteration_count = atoi(argv[1]);

    pthread_t threads[2];

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
        for (int j = 0; j < ARRAY_SIZE; j++) {
            kal[i][j] = i * ARRAY_SIZE + j;
            checker[i][j] = 0;
        }
    }
    printf("Initialized data\n");

    int csr_fd = open("/dev/hdlnocgen_c5p_dma_csr", O_RDWR);
    if (csr_fd < 0) {
        return csr_fd;
    }
    uint32_t writedata = 0;
    pwrite(csr_fd, &writedata, 4, (off_t)0xC);
    printf("DMA controller reset\n");

    for (int iter = 0; iter < iteration_count; iter++) {

        clock_gettime(CLOCK_MONOTONIC, &start);
        pthread_create(&threads[0], NULL, dma_read_thread, (void *)(uint64_t)1);
        pthread_create(&threads[1], NULL, dma_write_thread, (void *)(uint64_t)0);
        pthread_join(threads[0], NULL);
        pthread_join(threads[1], NULL);
        pthread_create(&threads[0], NULL, dma_read_thread, (void *)(uint64_t)0);
        pthread_create(&threads[1], NULL, dma_write_thread, (void *)(uint64_t)1);
        pthread_join(threads[0], NULL);
        pthread_join(threads[1], NULL);
        clock_gettime(CLOCK_MONOTONIC, &stop);

        for (int i = 0; i < DMA_CHANNEL_COUNT; i += 2) { // even
            for (int j = 0; j < ARRAY_SIZE; j++) {
                if (kal[i][j] != checker[i + 1][j]) {
                    fail[i]++;
                }
            }
        }

        for (int i = 1; i < DMA_CHANNEL_COUNT; i += 2) { // odd
            for (int j = 0; j < ARRAY_SIZE; j++) {
                if (kal[i][j] != checker[i - 1][j]) {
                    fail[i]++;
                }
            }
        }

        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
            for (int j = 0; j < ARRAY_SIZE; j++) {
                checker[i][j] = 0;
            }
        }

        elapsed += (stop.tv_sec*1e9 + stop.tv_nsec) - (start.tv_sec*1e9 + start.tv_nsec);
    }
    printf("All data echoed through DMA\n");

    printf("Fail array: ");
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        printf("%d ", fail[i]);
    }
    printf("\n");

    uint64_t bitcount = (sizeof(kal) + sizeof(checker))*8*iteration_count;
    printf("Speed: %lf Gbit/sec\n", bitcount/elapsed);
}