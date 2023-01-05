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
