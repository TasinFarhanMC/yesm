
# yesm

**yesm** is an implementation of **GNU yes** written in Linux **Assembly**.
## Benchmarks

> **Note:** The benchmarks are generated using GitHub Actions runners (x86_64 Linux) with the latest commit of **yesm**.

Benchmark for the x86_64 build of **yesm**:  
- [View summary (raw)](https://raw.githubusercontent.com/TasinFarhanMC/yesm/benchmarks/x86_64/benchmark.txt)  
- [View summary on GitHub](https://github.com/TasinFarhanMC/yesm/blob/benchmarks/x86_64/benchmark.txt)

For full verbose results, see:  
- [View verbose (raw)](https://raw.githubusercontent.com/TasinFarhanMC/yesm/benchmarks/x86_64/benchmark_verbose.txt)  
- [View verbose on GitHub](https://github.com/TasinFarhanMC/yesm/blob/benchmarks/x86_64/benchmark_verbose.txt)## Build

Clone and build non SIMD version:

```bash
git clone https://github.com/TasinFarhanMC/yesm
cd yesm/x86_64
make -j $(nproc)
````

Run the default build:

```bash
./build/yesm
```

---

For SIMD builds (currently only SSE2):

```bash
git clone https://github.com/TasinFarhanMC/yesm
cd yesm/x86_64
make extras -j $(nproc)
```

Run the SIMD SSE2 build:

```bash
./build/yesm_sse2
```
## Running Benchmarks

To run benchmarks, cd to the architecture directory (e.g., `./x86_64`):

```bash
./benchmarks.sh
```

* **Summary results** will be saved in `./benchmarks.txt`.
* **Verbose results** will be saved in `./benchmarks_verbose.txt`.
