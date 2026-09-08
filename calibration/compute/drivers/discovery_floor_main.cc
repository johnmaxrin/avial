// Benchmarks the baseline runtime hardware topology scanning overhead for roofline parameter c.
//
// The c term captures fixed startup latency incurred during runtime initialization when discovering
// machine capabilities (via hwloc topology inspection or Linux sysfs PCI scans) inside
// libs/runtimeHardwareMapping.cc. Rather than inferring c indirectly from multi-variable regression
// residuals across kernel runs, this standalone driver directly quantifies empirical discovery latency.
//
// Output schema:
//   CALIBRATION,c_floor,<reps>,<seconds_per_discovery>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <dirent.h>

#if __has_include(<hwloc.h>)
#define DHIR_HAVE_HWLOC 1
#include <hwloc.h>
#endif

using clk = std::chrono::steady_clock;

static long long readFirstLong(const char *path) {
    std::FILE *f = std::fopen(path, "r");
    if (!f) return -1;
    long long v = -1;
    if (std::fscanf(f, "%lli", &v) != 1) v = -1;
    std::fclose(f);
    return v;
}

static int sysfsGpuCount() {
    DIR *dir = opendir("/sys/bus/pci/devices");
    if (!dir) return 0;
    int gpus = 0;
    while (struct dirent *ent = readdir(dir)) {
        if (ent->d_name[0] == '.') continue;
        char path[512];
        std::snprintf(path, sizeof(path), "/sys/bus/pci/devices/%s/vendor", ent->d_name);
        long long vendor = readFirstLong(path);
        if (vendor != 0x10de) continue;
        std::snprintf(path, sizeof(path), "/sys/bus/pci/devices/%s/class", ent->d_name);
        long long cls = readFirstLong(path);
        if (cls >= 0 && (cls >> 16) == 0x03) ++gpus;
    }
    closedir(dir);
    return gpus;
}

static double sysfsDiscoverySeconds(int reps, int *gpus) {
    auto t0 = clk::now();
    int found = 0;
    for (int i = 0; i < reps; ++i) found = sysfsGpuCount();
    *gpus = found;
    return std::chrono::duration<double>(clk::now() - t0).count() / reps;
}

static double hwlocDiscoverySeconds(int reps, int *gpus) {
#if DHIR_HAVE_HWLOC
    auto t0 = clk::now();
    int found = 0;
    for (int i = 0; i < reps; ++i) {
        hwloc_topology_t topology;
        hwloc_topology_init(&topology);
        hwloc_topology_set_components(topology, HWLOC_TOPOLOGY_COMPONENTS_FLAG_BLACKLIST, "gl");
        hwloc_topology_set_io_types_filter(topology, HWLOC_TYPE_FILTER_KEEP_IMPORTANT);
        hwloc_topology_load(topology);
        found = 0;
        hwloc_obj_t obj = nullptr;
        while ((obj = hwloc_get_next_obj_by_type(topology, HWLOC_OBJ_PCI_DEVICE, obj))) {
            if (obj->attr && (obj->attr->pcidev.class_id >> 8 == 0x03) &&
                obj->attr->pcidev.vendor_id == 0x10de)
                ++found;
        }
        hwloc_topology_destroy(topology);
    }
    *gpus = found;
    return std::chrono::duration<double>(clk::now() - t0).count() / reps;
#else
    (void)reps;
    *gpus = -1;
    return -1.0;
#endif
}

int main(int argc, char **argv) {
    int reps = argc > 1 ? std::atoi(argv[1]) : 5;
    if (reps < 1) reps = 5;

    int gpusHwloc = 0, gpusSysfs = 0;
    double tHwloc = hwlocDiscoverySeconds(reps, &gpusHwloc);
    double tSysfs = sysfsDiscoverySeconds(reps, &gpusSysfs);

    double c_floor = (tHwloc > 0.0) ? tHwloc : tSysfs;
    const char *source = (tHwloc > 0.0) ? "hwloc" : "sysfs";

    std::printf("CALIBRATION,c_floor,%d,%.9g\n", reps, c_floor);
    std::printf("# discovery floor c=%.3f ms (source: %s, hwloc=%.3f ms, sysfs=%.3f ms)\n",
                c_floor * 1e3, source, tHwloc * 1e3, tSysfs * 1e3);

    return 0;
}
