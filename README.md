# ps-random-wait

Randomly selects and suspends child thread(processes) of the specified process.

This is intended to be used in testing to find timing bugs.

## how to test
``` bash
# terminal A
./multi-processes-test.sh

# terminal B
./ps-random-wait "$(pgrep -alf 'multi-processes-test.sh' | grep bash | cut -d' ' -f1)"
```
