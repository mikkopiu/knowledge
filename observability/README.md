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
| spath input=_raw path=yourobj{}.key1 output="key1"
| spath input=_raw path=yourobj{}.key2 output="key2"
| spath input=_raw path=yourobj{}.key3 output="key3"
| fields - _*
| fields key1 key2 key3
| eval data=mvzip(mvzip(key1,key2),key3)
| fields - key1 key2 key3
| mvexpand data
| eval data=split(data,",")
| eval key1=mvindex(data,0),key2=mvindex(data,1),key3=mvindex(data,2)
| eval _time=mvindex(data,3)
| fields - data
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
