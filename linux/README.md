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

### lightdm configuration

I.e. when you want to change the default greeter ("login page")
when using `lightdm`.

The configuration files are located in (on Ubuntu 18.04 LTS at least):
`/usr/share/lightdm/lightdm.conf.d/`.

For example, using the Patheon greeter might look something like:

```
[Seat:*]
greeter-session=io.elementary.greeter
user-session=pantheon
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

### Map lines to Bash array

```bash
mapfile -t my_array < file.txt
```

### Browse gzipped (log) files

```sh
zcat /var/log/messages-somedate.gz | less
```

### List open ports with awk

```sh
awk 'NR>1' /proc/net/tcp | awk '{x=strtonum("0x"substr($2,index($2,":")-2,2)); for (i=5; i>0; i-=2) x = x"."strtonum("0x"substr($2,i,2))}{print x":"strtonum("0x"substr($2,index($2,":")+1,4))}'
```

### Test TCP connectivity in constrained environments

```sh
nc -vz <address> <port>
```

