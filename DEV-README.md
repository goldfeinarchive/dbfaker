## Notes on setting up 

### Python Development Setup

#### Prerequisites
1. Install python
    ```shell
    brew install python
    xcode-select --install
    brew install pyenv  
    brew install pyenv-virtualenv
    ```
2. Add hub command to expand git functionality
    ```shell
    brew install hub
    ```
3. Create a Github Personal Access token [here](https://github.com/settings/tokens) and add it to your `.zshrc`
    ```shell
    export GITHUB_TOKEN=<your-token>
    ```
4. Add settings to .zshrc
    ```shell
    alias python=python3
    alias pip=pip3
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    ```
5. Create a virtual environment for <your-project>
    ```shell
    pyenv install 3.11.3
    pyenv virtualenv 3.11.3 <your-project>
    ```

##### Notes
To upgrade to newer versions of python you may need to upgrade pyenv to have the latest 
versions appear in `pyenv install --list`
```shell
brew upgrade pyenv
``` 

## Useful Makefile commands
`make version v=major|minor|patch` Will increment the corresponding portion of version number in the pyproject.toml 
file, tag the commit, and push the changes to the repository

`make push` Will login to ecr, build the docker image locally, and push the images to ecr.  
Once with latest tag, and again with the version tag from poetry. 

In order to build multi-architecture images you first 
need to setup a buildx builder.  ` docker buildx create --use` This only needs to be done once per docker installation.  

## Notes on Development
Before committing code, run `make lint` to ensure that the code is properly formatted.  
This will run `black`, `isort`, `pylint`, and `flake8` on the code.  If any of these fail, the commit will be rejected.

Also run `make test` to ensure nothing has been broken.  This will run `pytest` on the code.  If any tests fail, 
the commit will be rejected.

Once everything passes, commit your changes, push to the repository, run `make version v=patch`,and create a pull 
request.
