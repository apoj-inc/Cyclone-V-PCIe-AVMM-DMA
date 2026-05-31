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

pthread_t subthreads[DMA_CHANNEL_COUNT][2];

void *dma_read (void *index) {
    uint64_t index_int = (uint64_t)index;
    read(fd[index_int], checker[index_int], sizeof(checker[index_int]));
}
void *dma_write (void *index) {
    uint64_t index_int = (uint64_t)index;
    write(fd[index_int], kal[index_int], sizeof(kal[index_int]));
}

void *dma_test_parallel (void *index) {
    uint64_t index_int = (uint64_t)index;

    pthread_create(&subthreads[index_int][0], NULL, dma_read, (void *)index_int);
    pthread_create(&subthreads[index_int][1], NULL, dma_write, (void *)index_int);

    pthread_join(subthreads[index_int][0], NULL);
    pthread_join(subthreads[index_int][1], NULL);
}

void *dma_test (void *index) {
    int index_int = (uint64_t)index;
    write(fd[index_int], kal[index_int], sizeof(kal[index_int]));
    read(fd[index_int], checker[index_int], sizeof(checker[index_int]));
}

int main (int argc, char **argv) {
    if (argc < 3) {
        return -1;
    }

    int iteration_count = atoi(argv[1]);
    int parallel = atoi(argv[2]);

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

    int csr_fd = open("/dev/hdlnocgen_c5p_dma_csr", O_RDWR);
    if (csr_fd < 0) {
        return csr_fd;
    }
    uint32_t writedata = 0;
    pwrite(csr_fd, &writedata, 4, (off_t)0xC);
    printf("DMA controller reset\n");

    for (int iter = 0; iter < iteration_count; iter++) {
        
        if (parallel) {
            clock_gettime(CLOCK_MONOTONIC, &start);
            for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
                pthread_create(&threads[i], NULL, dma_test_parallel, (void *)(uint64_t)i);
            }
            for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
                pthread_join(threads[i], NULL);
            }
            clock_gettime(CLOCK_MONOTONIC, &stop);
        }
        else {
            clock_gettime(CLOCK_MONOTONIC, &start);
            for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
                pthread_create(&threads[i], NULL, dma_test, (void *)(uint64_t)i);
            }
            for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
                pthread_join(threads[i], NULL);
            }
            clock_gettime(CLOCK_MONOTONIC, &stop);
        }

        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
            for (int j = 0; j < ARRAY_SIZE; j++) {
                if (kal[i][j] != checker[i][j]) {
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
    printf("All channels read from dma\n");

    printf("Fail array: ");
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) {
        printf("%d ", fail[i]);
    }
    printf("\n");

    uint64_t bitcount = (sizeof(kal) + sizeof(checker))*8*iteration_count;
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
