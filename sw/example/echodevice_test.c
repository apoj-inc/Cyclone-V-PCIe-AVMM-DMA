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
#define ITERATION_COUNT   (uint64_t)(10000)

uint64_t kal[DMA_CHANNEL_COUNT][ARRAY_SIZE];
uint64_t checker[DMA_CHANNEL_COUNT][ARRAY_SIZE];
int fd[DMA_CHANNEL_COUNT];
int fail[DMA_CHANNEL_COUNT];

void *dma_test (void *index) {
    int index_int = (uint64_t)index;
    write(fd[index_int], kal[index_int], sizeof(kal[index_int]));
    read(fd[index_int], checker[index_int], sizeof(checker[index_int]));
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
        for (int j = 0; j < ARRAY_SIZE; j++) {
            kal[i][j] = j * (i + 1);
            checker[i][j] = 0;
        }
    }
    printf("All channels initialized data\n");

    for (int iter = 0; iter < ITERATION_COUNT; iter++) {

        clock_gettime(CLOCK_MONOTONIC, &start);
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
            pthread_create(&threads[i], NULL, dma_test, (void *)(uint64_t)i);
        }
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
            pthread_join(threads[i], NULL);
        }
        clock_gettime(CLOCK_MONOTONIC, &stop);

        elapsed += (stop.tv_sec*1e9 + stop.tv_nsec) - (start.tv_sec*1e9 + start.tv_nsec);
    }
    printf("All channels read from dma\n");

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        for (int j = 0; j < ARRAY_SIZE; j++) {
            if (kal[i][j] != checker[i][j]) {
                fail[i]++;
            }
        }
    }
    printf("Fail array: ");
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        printf("%d ", fail[i]);
    }
    printf("\n");

    uint64_t bitcount = ARRAY_SIZE*8*8*DMA_CHANNEL_COUNT*2*ITERATION_COUNT;
    printf("Speed: %lf Gbit/sec\n", bitcount/elapsed);

    printf("Checking external interrupts\n");

    int fd_csr = open("/dev/hdlnocgen_c5p_env_csr", O_RDWR);
    int fd_irq = open("/dev/hdlnocgen_c5p_user_irq", O_RDWR);

    uint32_t assert_irq = 0xFFFFFFFF;
    uint8_t irq_status;
    uint8_t deassert_irq = 0;

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        pwrite(fd_csr, &assert_irq, 4, (off_t)(0x4*i));
        printf("Channel %d assert IRQ sent\n", i);
        do {
            pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)(i));
        } while (irq_status != 1);
        printf("Channel %d IRQ asserted\n", i);
        pwrite(fd_irq, &deassert_irq, sizeof(deassert_irq), (off_t)(i));
        printf("Channel %d deassert IRQ sent\n", i);
        do {
            pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)(i));
        } while (irq_status != 0);
        printf("Channel %d IRQ deasserted\n", i);
        
        printf("Channel %d IRQ check success\n", i);
    }

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        close(fd[i]);
    }
}
