# Linux / shell / etc

## Miscellaneous trivia

### Stop script execution on error

Useful for provision or boot scripts where no errors are acceptable.

```
#!/bin/sh -e
```

or 

```sh
#!/bin/sh
set -o errexit # or shorter: set -e
```

## Snippets

### Create progress bar in shell script

```sh
#!/bin/bash -e

echo -ne 'Loading: ###        (33%)\r'
sleep 1
echo -ne 'Loading: ######     (66%)\r'
sleep 1
echo -ne 'Loading: ########## (100%)\r'
echo -ne '\n'
```
