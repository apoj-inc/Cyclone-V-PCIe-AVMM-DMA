#include <linux/types.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/device.h>
#include <linux/dma-mapping.h>
#include <linux/io-64-nonatomic-lo-hi.h>
#include <linux/delay.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/wait.h>
#include <asm/param.h> 

#define DRIVER_NAME "hdlnocgen_c5p_driver"
#define DMA_BUFFER_SIZE 4194304

DECLARE_WAIT_QUEUE_HEAD(dma_wq);

//Device globs
uint64_t b0_start, b0_size;
uint64_t b2_start, b2_size;
uint16_t vendor, device;

// Device file globs
static dev_t driver_dev_nr;
static struct cdev driver_cdev;
static struct class *driver_class;
static char *hdlnocgen_devnode(const struct device *dev, umode_t *mode) {
    if (!mode) {
        return NULL;
    }
    if (!dev) {
        return NULL;
    }
    *mode = 0666;
    return NULL;
}

// DMA config globs
static uint16_t dma_channel_count;
void __iomem *bar0_ptr, *bar2_ptr;
int dma_irq_index[16] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
uint8_t dma_irq_flags[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

int user_irq_index[16] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
uint8_t user_irq_flags[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

// DMA pointer globs
static void *cpu_addr[16];
static dma_addr_t dma_handle[16];

// Error handling globs
int err, err_index = 0;


static ssize_t read_from_pci(struct file *filp, char __user *user_buf, size_t len, loff_t *off) {
    int channel = MINOR(filp->f_inode->i_rdev);

    if (channel == dma_channel_count) {
        int retval = len - 1;
        if (retval == -1) {
            return retval;
        }
        if (*off > 16) {
            return -EINVAL;
        }
        retval += copy_to_user(user_buf, user_irq_flags+*off, 1);

        return retval;
    }
    else if (channel == dma_channel_count+1) {
        int retval = len - 4;
        if (retval < 0) {
            return retval;
        }
        uint32_t read_value = ioread32(bar2_ptr+0x2000+*off);
        retval += copy_to_user(user_buf, &read_value, 4);

        return retval;
    }
    else if (channel == dma_channel_count+2) {
        int retval = len - 4;
        if (retval < 0) {
            return retval;
        }
        if ((uint64_t)*off > 0xC) {
            return -EINVAL;
        }
        uint32_t read_value = ioread32(bar2_ptr+0x0000+*off);
        retval += copy_to_user(user_buf, &read_value, 4);

        return retval;
    }

    //printk(KERN_INFO "hdlnocgen_c5p_driver: Read request to channel %u\n", channel);

    if (len > DMA_BUFFER_SIZE) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Requested to read %lu bytes, which is larger than size of DMA buffer (%llu bytes)\n", len, (uint64_t)DMA_BUFFER_SIZE);
        return -ENOMEM;
    }

    iowrite64((((uint64_t)len) << 32) | 0, bar2_ptr + 0x1000 + channel*0x10);
    //printk(KERN_INFO "hdlnocgen_c5p_driver: Read from DMA channel %d command sent\n", channel);

    uint32_t jiffies = wait_event_interruptible_timeout(dma_wq, dma_irq_flags[channel] == 1, HZ*2);
    if (!jiffies) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Read from DMA channel %d timeout\n", channel);
        return -1;
    }
    dma_irq_flags[channel] = 0;

    //printk(KERN_INFO "hdlnocgen_c5p_driver: Read from DMA channel %d finished successfully\n", channel);

    uint64_t not_copied = copy_to_user(user_buf, cpu_addr[channel], len);

    if (not_copied) {
        printk(KERN_WARNING "hdlnocgen_c5p_driver: %llu bytes of data failed to copy to kernel\n", not_copied);
    }

    return not_copied;
}

static ssize_t write_to_pci(struct file *filp, const char __user *user_buf, size_t len, loff_t *off) {
    int channel = MINOR(filp->f_inode->i_rdev);

    if (channel == dma_channel_count) {
        int retval = len - 1;
        if (retval == -1) {
            return 0;
        }
        if (*off > 16) {
            return -EINVAL;
        }
        retval += copy_from_user(user_irq_flags+*off, user_buf, 1);

        return retval;
    }
    else if (channel == dma_channel_count+1) {
        int retval = len - 4;
        if (retval < 0) {
            return retval;
        }
        uint32_t write_value;
        retval += copy_from_user(&write_value, user_buf, 4);
        iowrite32(write_value, bar2_ptr+0x2000+*off);

        return retval;
    }
    else if (channel == dma_channel_count+2) {
        int retval = len - 4;
        if (retval < 0) {
            return retval;
        }
        if ((uint64_t)*off > 0xC) {
            return -EINVAL;
        }
        uint32_t write_value;
        retval += copy_from_user(&write_value, user_buf, 4);
        iowrite32(write_value, bar2_ptr+0x0000+*off);

        return retval;
    }

    //printk(KERN_INFO "hdlnocgen_c5p_driver: Write request to channel %u\n", channel);

    if (len > DMA_BUFFER_SIZE) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Requested to write %lu bytes, which is larger than size of DMA buffer (%llu bytes)\n", len, (uint64_t)DMA_BUFFER_SIZE);
        return -ENOMEM;
    }

    uint64_t not_copied = copy_from_user(cpu_addr[channel], user_buf, len);

    if (not_copied) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: %llu bytes of data failed to copy to kernel. No transfer\n", not_copied);
        return not_copied;
    }

    iowrite64((((uint64_t)(len-not_copied)) << 32) | 0, bar2_ptr + 0x1008 + channel*0x10);
    //printk(KERN_INFO "hdlnocgen_c5p_driver: Write to DMA channel %d command sent\n", channel);

    uint32_t jiffies = wait_event_interruptible_timeout(dma_wq, dma_irq_flags[channel] == 1, HZ*2);
    if (!jiffies) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Write to DMA channel %d timeout\n", channel);
        return -1;
    }
    dma_irq_flags[channel] = 0;

    //printk(KERN_INFO "hdlnocgen_c5p_driver: Write to DMA channel %d finished successfully\n", channel);

    return not_copied;
}


static struct file_operations fops = {
	.read = read_from_pci,
    .write = write_to_pci
};


static struct pci_device_id my_driver_id_table[] = {
    { PCI_DEVICE(0x1172, 0xd800) },
    { PCI_DEVICE(0x1172, 0x00ff) },
    {0,}
};
MODULE_DEVICE_TABLE(pci, my_driver_id_table);

static int hdlnocgen_dma_probe(struct pci_dev *pdev, const struct pci_device_id *ent);

static void hdlnocgen_dma_remove(struct pci_dev *pdev);


static struct pci_driver hdlnocgen_dma_driver = {
    .name = "hdlnocgen_c5p_dma",
    .id_table = my_driver_id_table,
    .probe = hdlnocgen_dma_probe,
    .remove = hdlnocgen_dma_remove
};



static irqreturn_t dma_finish(int irq, void *dev) {
    for (int i = 0; i < dma_channel_count; i++) {
        if (dma_irq_index[i] == irq) {
            dma_irq_flags[i] = 1;
            break;
        }
    }
    wake_up_all(&dma_wq);
    return IRQ_HANDLED;
}

static irqreturn_t user_msix_pend(int irq, void *dev) {
    for (int i = 0; i < dma_channel_count; i++) {
        if (user_irq_index[i] == irq) {
            user_irq_flags[i] = 1;
            break;
        }
    }
    return IRQ_HANDLED;
}

static int hdlnocgen_dma_probe(struct pci_dev *pdev, const struct pci_device_id *ent) {
    pci_read_config_word(pdev, PCI_VENDOR_ID, &vendor);
    pci_read_config_word(pdev, PCI_DEVICE_ID, &device);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Device vid: 0x%X\n", vendor);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Device pid: 0x%X\n", device);

    // PCIe memory enable
    err = pci_enable_device_mem(pdev);
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to enable PCIe device's memory\n");
        goto pci_release_bar2;
    }

    // PCIe device BAR[0] req
    err = pci_request_region(pdev, 0, DRIVER_NAME);
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to reserve BAR0\n");
        return err;
    }
    // PCIe device BAR[2] req
    err = pci_request_region(pdev, 2, DRIVER_NAME);
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to reserve BAR2\n");
        goto pci_release_bar0;
    }

    // Get BAR[0] addresses
    b0_start = pci_resource_start(pdev, 0);
    b0_size = pci_resource_len(pdev, 0);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[0]: 0x%llx-0x%llx\n", b0_start, b0_start + b0_size - 1);
    // Get BAR[2] addresses
    b2_start = pci_resource_start(pdev, 2);
    b2_size = pci_resource_len(pdev, 2);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[2]: 0x%llx-0x%llx\n", b2_start, b2_start + b2_size - 1);

    // Remap BARs to memory
    bar0_ptr = ioremap(b0_start, b0_size);
    if (!bar0_ptr) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to ioremap BAR[0]...\n");
        err = -ENOMEM;
        goto pci_disable;
    }
    bar2_ptr = ioremap(b2_start, b2_size);
    if (!bar2_ptr) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to ioremap BAR[2]...\n");
        err = -ENOMEM;
        goto unmap_bar0;
    }

    printk(KERN_INFO "hdlnocgen_c5p_driver: Extracting configuration info...\n");
    dma_channel_count = ioread32(bar2_ptr) & 0xFFFF;
    printk(KERN_INFO "hdlnocgen_c5p_driver: Extracting done. This DMA has %hu channels\n", dma_channel_count);

    // Register MSIs
    printk(KERN_INFO "hdlnocgen_c5p_driver: Allocating %hu DMA and %hu user interrupts\n", dma_channel_count, dma_channel_count);
    err = pci_alloc_irq_vectors(pdev, dma_channel_count*2, dma_channel_count*2, PCI_IRQ_MSIX);
    if (err < 0) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to register PCIe interrupts\n");
        goto unmap_bar2;
    }
    else if (err != dma_channel_count*2) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to allocate PCIe interrupts - %hu interrupts required, but %d alocated\n", dma_channel_count*2, err);
        goto msi_free;
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Allocated %d interrupts using MSIXs\n", err);


    // DMA address mask setup
    err = dma_set_mask_and_coherent(&(pdev->dev), DMA_BIT_MASK(64));
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to set DMA mask\n");
        goto msi_free;
    }

    // Register DMA IRQ handlers
    for (int i = 0; i < dma_channel_count; i++) {
        // Set IRQ handler
        dma_irq_index[i] = pci_irq_vector(pdev, i);
        printk(KERN_INFO "hdlnocgen_c5p_driver: DMA IRQ for channel %d is %d\n", i, dma_irq_index[i]);

        err = request_irq(dma_irq_index[i], dma_finish, IRQF_TRIGGER_RISING, DRIVER_NAME, NULL);
        if (err) {
            printk(KERN_INFO "hdlnocgen_c5p_driver: Failed to register DMA IRQ handler for channel %d\n", i);
            goto unregister_irq;
        }
        printk(KERN_INFO "hdlnocgen_c5p_driver: Registered IRQ handler for DMA channel %d\n", i);

        err_index = i + 1;
    }

    // Register user IRQ handlers
    for (int i = dma_channel_count; i < dma_channel_count*2; i++) {
        // Set IRQ handler
        user_irq_index[i-dma_channel_count] = pci_irq_vector(pdev, i);
        printk(KERN_INFO "hdlnocgen_c5p_driver: User IRQ for channel %d is %d\n", i-dma_channel_count, user_irq_index[i-dma_channel_count]);

        err = request_irq(user_irq_index[i-dma_channel_count], user_msix_pend, IRQF_TRIGGER_RISING, DRIVER_NAME, NULL);
        if (err) {
            printk(KERN_INFO "hdlnocgen_c5p_driver: Failed to register user IRQ handler for channel %d\n", i-dma_channel_count);
            goto unregister_user_irq;
        }
        printk(KERN_INFO "hdlnocgen_c5p_driver: Registered IRQ handler for user channel %d\n", i-dma_channel_count);
        
        err_index = i + 1;
    }

    // Allocate DMA buffers
    uint32_t next_struct_addr = (ioread32(bar2_ptr) & 0xFFFF0000) >> 16;
    printk(KERN_INFO "hdlnocgen_c5p_driver: Channel 0 struct addr is 0x%x\n", next_struct_addr);

    for (int i = 0; i < dma_channel_count; i++) {
        cpu_addr[i] = dma_alloc_coherent(&(pdev->dev), DMA_BUFFER_SIZE, &(dma_handle[i]), GFP_KERNEL);
        if (!cpu_addr[i]) {
            printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to allocate %llu bytes for DMA buffer channel %d\n", (uint64_t)DMA_BUFFER_SIZE, i);
            err = ENOENT;
            goto free_dma;
        }
        printk(KERN_INFO "hdlnocgen_c5p_driver: Created %d bytes of dma bytes. Channel - %d, CPU addr - 0x%p, DMA addr - 0x%llx\n", DMA_BUFFER_SIZE, i, cpu_addr[i], dma_handle[i]);

        iowrite32(dma_handle[i], bar2_ptr + next_struct_addr + 4);
        iowrite32(dma_handle[i] >> 32, bar2_ptr + next_struct_addr + 8);
        printk(KERN_INFO "hdlnocgen_c5p_driver: Wrote DMA addr for channel %d\n", i);

        next_struct_addr = ioread32(bar2_ptr + next_struct_addr);
        printk(KERN_INFO "hdlnocgen_c5p_driver: Channel %d struct addr is 0x%x\n", i+1, next_struct_addr);

        err_index = i + 1;
    }

    // Driver device setup
    err = alloc_chrdev_region(&driver_dev_nr, 0, MINORMASK + 1, "hdlnocgen_c5p_cdev"); // get major and minor numbers allocated
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to reserve major and minor numbers\n");
        goto free_dma;
    }
    cdev_init(&driver_cdev, &fops);
    driver_cdev.owner = THIS_MODULE;

    err = cdev_add(&driver_cdev, driver_dev_nr, MINORMASK + 1);
    if (err) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Failed to create cdev\n");
        goto free_driver_dev_nr;
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Registered cdev with Major %d starting with Minor %d\n", MAJOR(driver_dev_nr), MINOR(driver_dev_nr)); // register cdev under these numbers

    driver_class = class_create("hdlnocgen_c5p_class");
    if (!driver_class) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Could not create class hdlnocgen_c5p_class\n");
        err = -ENOMEM;
        goto delete_driver_cdev;
    }
    driver_class->devnode = hdlnocgen_devnode;
    printk(KERN_INFO "hdlnocgen_c5p_driver: Created class hdlnocgen_c5p_class\n");

    for (int i = 0; i < dma_channel_count; i++) {
        if (!device_create(driver_class, &(pdev->dev), driver_dev_nr+i, NULL, "hdlnocgen_c5p%d", i)) {
            printk(KERN_ERR "hdlnocgen_c5p_driver: Could not create device file hdlnocgen_c5p%d\n", i);
            err = -ENOMEM;
            goto destroy_device_file;
        }
        printk(KERN_INFO "hdlnocgen_c5p_driver: Created device file hdlnocgen_c5p%d\n", i); // register cdev under these numbers

        err_index = i + 1;
    }

    if (!device_create(driver_class, &(pdev->dev), driver_dev_nr+dma_channel_count, NULL, "hdlnocgen_c5p_user_irq")) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Could not create device file hdlnocgen_c5p_user_irq\n");
        err = -ENOMEM;
        goto destroy_device_file;
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Created device file hdlnocgen_c5p_user_irq\n");

    if (!device_create(driver_class, &(pdev->dev), driver_dev_nr+dma_channel_count+1, NULL, "hdlnocgen_c5p_env_csr")) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Could not create device file hdlnocgen_c5p_env_csr\n");
        err = -ENOMEM;
        goto destroy_user_irq_file;
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Created device file hdlnocgen_c5p_env_csr\n");

    if (!device_create(driver_class, &(pdev->dev), driver_dev_nr+dma_channel_count+2, NULL, "hdlnocgen_c5p_dma_csr")) {
        printk(KERN_ERR "hdlnocgen_c5p_driver: Could not create device file hdlnocgen_c5p_dma_csr\n");
        err = -ENOMEM;
        goto destroy_env_csr_file;
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Created device file hdlnocgen_c5p_dma_csr\n");

    // Set PCIe as master
    pci_set_master(pdev);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Bus mastered by PCIe device\n");

    return 0;

destroy_env_csr_file:
    device_destroy(driver_class, driver_dev_nr+dma_channel_count+1);
destroy_user_irq_file:
    device_destroy(driver_class, driver_dev_nr+dma_channel_count);
destroy_device_file:
    for (int i = 0; i < err_index; i++) {
        device_destroy(driver_class, driver_dev_nr+i);
    }
    err_index = dma_channel_count;
//delete_driver_class:
	class_unregister(driver_class);
	class_destroy(driver_class);
delete_driver_cdev:
	cdev_del(&driver_cdev);
free_driver_dev_nr:
    unregister_chrdev_region(driver_dev_nr, MINORMASK + 1);
free_dma:
    for (int i = 0; i < err_index; i++) {
        dma_free_coherent(&(pdev->dev), DMA_BUFFER_SIZE, cpu_addr[i], dma_handle[i]);
    }
    err_index = dma_channel_count;
unregister_user_irq:
    for (int i = 0; i < err_index; i++) {
        free_irq(user_irq_index[i], NULL);
    }
    err_index = dma_channel_count;
unregister_irq:
    for (int i = 0; i < err_index; i++) {
        free_irq(dma_irq_index[i], NULL);
    }
    err_index = dma_channel_count;
msi_free:
    pci_free_irq_vectors(pdev);
unmap_bar2:
    iounmap(bar2_ptr);
unmap_bar0:
    iounmap(bar0_ptr);
pci_release_bar2:
    pci_release_region(pdev, 2);
pci_release_bar0:
    pci_release_region(pdev, 0);
pci_disable:
    pci_disable_device(pdev);

    return err;
}

static void hdlnocgen_dma_remove(struct pci_dev *pdev) {
    pci_clear_master(pdev);
    printk(KERN_INFO "hdlnocgen_c5p_driver: PCIe device unmastered\n");

    device_destroy(driver_class, driver_dev_nr+dma_channel_count+2);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted file hdlnocgen_c5p_dma_csr\n");

    device_destroy(driver_class, driver_dev_nr+dma_channel_count+1);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted file hdlnocgen_c5p_env_csr\n");

    device_destroy(driver_class, driver_dev_nr+dma_channel_count);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted file hdlnocgen_c5p_user_irq\n");

    for (int i = 0; i < dma_channel_count; i++) {
        device_destroy(driver_class, driver_dev_nr+i);
        printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted file hdlnocgen_c5p%d\n", i);
    }

	class_unregister(driver_class);
	class_destroy(driver_class);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted cdev class\n");

	cdev_del(&driver_cdev);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Deleted driver cdev\n");

    unregister_chrdev_region(driver_dev_nr, MINORMASK + 1);
    printk(KERN_INFO "hdlnocgen_c5p_driver: Unregistered devnr region\n");

    for (int i = 0; i < dma_channel_count; i++) {
        dma_free_coherent(&(pdev->dev), DMA_BUFFER_SIZE, cpu_addr[i], dma_handle[i]);
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: DMA buffers freed\n");

    for (int i = 0; i < dma_channel_count; i++) {
        free_irq(dma_irq_index[i], NULL);
    }
    printk(KERN_INFO "hdlnocgen_c5p_driver: Freed IRQ handlers\n");

    for (int i = 0; i < dma_channel_count; i++) {
        free_irq(user_irq_index[i], NULL);
    }

    pci_free_irq_vectors(pdev);
    printk(KERN_INFO "hdlnocgen_c5p_driver: PCIe MSIXs released\n");

    iounmap(bar2_ptr);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[2] unmapped\n");

    iounmap(bar0_ptr);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[0] unmapped\n");

    pci_release_region(pdev, 2);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[2] released\n");

    pci_release_region(pdev, 0);
    printk(KERN_INFO "hdlnocgen_c5p_driver: BAR[0] released\n");

    pci_disable_device(pdev);
    printk(KERN_INFO "hdlnocgen_c5p_driver: PCIe device disabled\n");

    printk(KERN_INFO "hdlnocgen_c5p_driver: User IRQs pending: ");
    for (int i = 0; i < dma_channel_count; i++) {
        printk(KERN_CONT "%d ", user_irq_flags[i]);
    }

}


static int __init init_hdlnocgen_dma_driver (void) {

	return pci_register_driver(&hdlnocgen_dma_driver);
}

static void __exit cleanup_hdlnocgen_dma_driver (void) {

	pci_unregister_driver(&hdlnocgen_dma_driver);
}

module_init(init_hdlnocgen_dma_driver);
module_exit(cleanup_hdlnocgen_dma_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("stargazer");
MODULE_DESCRIPTION("A PCIe DMA driver for a controller on a Terasic openVINO Starter kit devboard's FPGA");
