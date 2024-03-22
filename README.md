# ps-random-wait

## how to test
``` bash
# terminal A
./multi-processes-test.sh

# terminal B
./ps-random-wait "$(pgrep -alf 'multi-processes-test.sh' | grep bash | cut -d' ' -f1)"
```
