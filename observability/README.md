# Observability & monitoring etc

## Splunk

### List available indeces

```txt
| eventcount summarize=false index=* | dedup index | fields index
```

### List available metrics and dimensions in an index

```txt
| mcatalog values(_dims) WHERE "index"="name_of_index" GROUPBY metric_name index host
| rename values(_dims) AS dimensions 
| table metric_name dimensions index
```

### Expand a huge JSON array into events

**NOTE:** This solution only works when the field names are known.

`mvexpand` and `spath` have some limitations (e.g. 5000 characters) when used without the correct arguments. This way seems to work correctly:

```txt
<base search>
| spath yourarr{} output=yourarr ```Expand yourarr entries into separate rows via spath to allow Splunk to use streaming; avoid memory issues```
| fields - _raw ```mvexpand will run out of memory if the _raw strings are kept```
| mvexpand yourarr
| spath input=yourarr
<further processing>
```

### Dashboards

#### Create 2x2 grid of single values

Put an empty `<html>` between sets of `<single>` tags to create a vertical split.

```xml
<panel>
  <single>...</single>
  <single>...</single>
  <html></html>
  <single>...</single>
  <single>...</single>
</panel>
```
