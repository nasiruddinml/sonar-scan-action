# SonarQube Github Action
Integrate SonarQube with Github action to automate the code analysis. Detect bugs, vulnerabilities, code smells and get code coverage on each pull request or push.

## Pre-requisite
- Setup [SonarQube](https://docs.sonarqube.org/latest/setup/install-server/) server.


### You can add 2 workflows one for Develop and another one for Production. 

Add secrets from GitHub repository settings. Secret name is same as given in the *yml* file. ex: SONARQUBE_HOST

#### Must required secrets are SONARQUBE_HOST and SONARQUBE_TOKEN

- `SONARQUBE_HOST` - **_(Required)_** SonarQube URL.
- `SONARQUBE_TOKEN` - **_(Required)_** Authentication token of a SonarQube user. Please see [how to generate SonarQube token](https://docs.sonarqube.org/latest/user-guide/user-token/).
- `SCANNER_OPTIONS` - Please set this to "-Xmx3000m" to avoid heap memory issue. We can increase this upto 6000m. Please GitHub runner hardware resources [here](https://docs.github.com/en/free-pro-team@latest/actions/reference/specifications-for-github-hosted-runners#supported-runners-and-hardware-resources)
- `password` - using with the `login` username. Left blank if you are using authentication token.

projectVersion is an input parameter not a secret.

- `projectVersion` - **_(Required)_** The version we can give as input before building the workflow. example 1.1. Increase this value on each build like 1.2,1.3,1.4,...etc.

Please see `entrypoint.sh` file for more options.


`vim .github/workflows/devl.workflow.yml`

```
on: 
  workflow_dispatch:
    inputs:
      projectVersion:
        description: 'Version'
        required: true
name: Development
jobs:
  sonarQubeTrigger:
    name: SonarQube Trigger
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: SonarQube Scan
      uses: sijomc/sonarscan-action@master
      with:
        host: ${{ secrets.SONARQUBE_HOST }}
        login: ${{ secrets.SONARQUBE_TOKEN }}
        scannerOptions: ${{ secrets.SCANNER_OPTIONS }}
        exclusions: ${{ secrets.SONAR_EXCLUSIONS }}
        projectKey: "**Develop**"
        projectName: "**Develop**"
        projectVersion: ${{ github.event.inputs.projectVersion }}
```


`vim .github/workflows/prod.workflow.yml`


```
on: 
  workflow_dispatch:
    inputs:
      projectVersion:
        description: 'Version'
        required: true
name: Production
jobs:
  sonarQubeTrigger:
    name: SonarQube Trigger
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: SonarQube Scan
      uses: sijomc/sonarscan-action@master
      with:
        host: ${{ secrets.SONARQUBE_HOST }}
        login: ${{ secrets.SONARQUBE_TOKEN }}
        scannerOptions: ${{ secrets.SCANNER_OPTIONS }}
        exclusions: ${{ secrets.SONAR_EXCLUSIONS }}
        projectVersion: ${{ github.event.inputs.projectVersion }}        
```        


## SonarQube Analysis Parameters
You can have other sonar scanner [analysis parameters](https://docs.sonarqube.org/latest/analysis/analysis-parameters/) in configuration file named 'sonar-project.properties' inside root directory of your project repo.

Example : sonar-project.properties
```properties
sonar.projectKey=example-project
sonar.projectName=example-project
sonar.sources=.
sonar.sourceEncoding=UTF-8
```

Note: Please make sure your run the unit tests before running the sonar scanner to generate the code coverage report.