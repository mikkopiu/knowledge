# Node.js security tips

## Vulnerability scanning

nsp is a great CLI tool for scanning for known vulnerabilities in your project's npm dependencies: https://github.com/nodesecurity/nsp

### NSP in Jenkins

Tutorial: https://www.codeproject.com/Articles/1011520/Jenkins-Pipeline-Step-Node-Security-Project

For `nsp@2.6.3`, the proper regex pattern is `([\w+-]+)\s+([\w\.-@]+)\s+>= *([\w\.-@]+)\s+(.*)\s+(.*)\s+`

and I also created a slightly improved Mapping script:

```groovy
import hudson.plugins.warnings.parser.Warning  
import hudson.plugins.analysis.util.model.Priority

String msg = "Vulnerability found in ${matcher.group(1)}, version ${matcher.group(2)}, patched in ${matcher.group(3)}. Dependency path: ${matcher.group(4)}. More info: <a href=\"${matcher.group(5)}\">${matcher.group(5)}</a>"

return new Warning('package.json', 0, "NSP Warning", 'VULN1', msg, Priority.HIGH);
```
