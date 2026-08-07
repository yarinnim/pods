# SONARQUBE
SonarQube is an open-source, industry-leading platform for continuous inspection of code quality 
and security. It enables developers to automatically scan source code to detect bugs,
vulnerabilities, and code smells, supporting better, safer, and more maintainable software development.


## With sonarQube it helps with: 
  - Code Quality Checking
  - Security Scanning
  - CI/CD Integration 


## Main Component
  - SonarQube Server : The dashboard or UI where report are stored and displayed.
  - SonarScanner : The tool that scans your code and sends results to SonarQube.
  - SonarQube Database: Stores analysis history and configuration.


## Create SonarQube Project

**Step 1: Setup Project**
  1. Open SonarQube UI
  2. Login (default: admin / admin)
  3. Create new project:
    - Project Key: `my-project`
    - Display Name: anything you want
  4. Generate token:
    - Go to My Account → Security

**Step 2: Configure CI/CD Variables**
      Store your credentials securely in your CI/CD platform's to keep them out of your source code.

    - SONAR_TOKEN: The token you just generated.
    - SONAR_HOST_URL: The URL of your SonarQube server (e.g., https://sonarqube.mydomain.com).

**Step 3: Create sonar-project.properties** ( Optional if you want to put it inside your pipeline )
        Create this file in your root directory to define project metadata:

          sonar.projectKey=my-project
          sonar.projectName=My Project
          sonar.sources=src
          sonar.host.url=http://localhost:9000
          sonar.exclusions=node_modules/**

**Step 4 : Run Sonar Scanner in GitLab**
        Add this job to your .gitlab-ci.yml.

        sonarqube-check:
            image: sonarsource/sonar-scanner-cli:latest
            
            script: 
                - sonar-scanner
                ## Optional if you have sonar-project.properties file
                    -Dsonar.projectKey=${APP}
                    -Dsonar.projectName=${APP}
                    -Dsonar.sources=apps/${APP}/src
                    -Dsonar.host.url=$SONAR_HOST_URL
                    -Dsonar.login=$SONAR_TOKEN
                    -Dsonar.exclusions=node_modules
            variables:
                SONAR_TOKEN: $SONAR_TOKEN
                SONAR_HOST_URL: $SONAR_HOST_URL
              ## Define the cache location inside the project directory
                SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"  
              ## Required for proper analysis and caching performance
                GIT_DEPTH: "0"

            only:
                - main
      
**How It Works**
Git Push → GitLab CI starts → Runner executes → SonarScanner runs → SonarQube receives results 

