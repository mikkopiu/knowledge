# Linux / shell / etc

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
