### Python template

This is a template for python command line interface (CLI) projects. 
It includes a Makefile for easy versioning, a Dockerfile for easy deployment, and a JenkinsFile for easy automation.

You need to have a python 3.11+ environment to use this template.  Please consult the [DEV-README](DEV-README.md)
file for more information on setting up your python environment.

## Installation for development
The following steps will get you up and running with a development environment for this project.

1) Set environmental variables for the new project name and new image name. These values
will be used to replace the placeholders in the project, Makefile and Dockerfile.
```bash
export NEW_PROJECT_NAME=<your-project>
export NEW_IMAGE_NAME=<your-image>
export NEW_PREFIX=<your-env-prefix>
```

2) Clone the repository and generate a new project from the template
```bash
git clone git@github.com:twocubedio/python_template.git
git init ${NEW_PROJECT_NAME}
cp -r python_template/* ${NEW_PROJECT_NAME}
cd ${NEW_PROJECT_NAME}
# Update references in file to new project name
sed -i '' 's/python_template/'$NEW_PROJECT_NAME'/g;s/python-template/'$NEW_IMAGE_NAME'/g'  pyproject.toml
sed -i '' 's/python_template/'$NEW_PROJECT_NAME'/g;s/python-template/'$NEW_IMAGE_NAME'/g'  Makefile
sed -i '' 's/python_template/'$NEW_PROJECT_NAME'/g;s/python-template/'$NEW_IMAGE_NAME'/g'  Dockerfile
sed -i '' 's/python_template/'$NEW_PROJECT_NAME'/g;s/python-template/'$NEW_IMAGE_NAME'/g;s/PT_PREFIX/'$NEW_PREFIX'/g'  python_template.sh
# Rename files and directories
mv python_template ${NEW_PROJECT_NAME}
mv python_template.sh ${NEW_PROJECT_NAME}.sh 
# Create Repo and push to github
hub create twocubedio/${NEW_PROJECT_NAME} 
git add -A
git commit -m "Initial commit of ${NEW_PROJECT_NAME} using python_template"
git push --set-upstream origin main
```


2) Create an ECR repository for the docker image 
```bash 
AWS_PROFILE=staging aws ecr create-repository --repository-name ${NEW_IMAGE_NAME}
```

3) Install dependencies
```bash
cd ${NEWPROJECT_NAME}
pyenv virtualenv 3.11.3 ${NEW_PROJECT_NAME}
pyenv local ${NEW_PROJECT_NAME}
pip install poetry
poetry install
```

4) Configure Jenkins Build Job
TBD

### References 

https://medium.com/@albertazzir/blazing-fast-python-docker-builds-with-poetry-a78a66f5aed0