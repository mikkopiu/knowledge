# python

- Python versions: [pyenv](https://github.com/pyenv/pyenv)
- Dependencies & virtual environments: [pipenv](https://pipenv.pypa.io/en/latest/install/)

## Known issues

### Incompatibility with linuxbrew

```sh
# In python:
>>> import inquirer
An error was found, but returning just with the version: No module named '_curses'

# or when installing Python version with pyenv:
pyenv install <version>
...
WARNING: The Python readline extension was not compiled. Missing the GNU readline lib?
```

-> temporarily remove `linuxbrew` from `PATH` and re-install the Python version:

```sh
pyenv uninstall <version>
OLD_PATH="$PATH"
export PATH="$(echo $PATH | tr : '\n' | grep -v linuxbrew | paste -s -d:)"
pyenv install <version>
export PATH="$OLD_PATH"
```

[source](https://github.com/pyenv/pyenv/issues/1479#issuecomment-610683526)

