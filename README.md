
# Super-Chess-Bros

  

The super cool awesome 2D platform fighter chess adaption made in Godot.

  

**Prerequisites**

Make sure you have the following installed on your machine:

Python 3.7 or newer ([https://www.python.org/downloads/](https://www.python.org/downloads/))

  

**Clone the Repository**

Open your terminal (Git Bash on Windows or Terminal on macOS/Linux) and run:

```bash

git  clone  https://github.com/MasonHall9987/Super-Chess-Bros

cd  your-repo

```

**Install Python Dependencies and Set Up Git Hooks**

```bash

python3  -m pip install --user  --upgrade pre-commit

python3  -m pip install --user  --upgrade "gdtoolkit==4.*"

python3  -m pre_commit install

  ```

**Verify Installation**

```bash

python3  -m  pre_commit  run  --all-files

  ```

**Usage**

Now,  every  time  you  make  a  Git  commit,  the  pre-commit  hook  will  automatically:

  

Lint  your  GDScript  files  using  gdlint

  

Format  your  GDScript  files  using  gdformat

  

If  linting  errors  are  found,  the  commit  will  be  blocked  until  you  fix  them.

  

**Additional Notes**

To  update  the  tooling  later,  run:

```bash

python3  -m pip install --user  --upgrade pre-commit gdtoolkit
```

To uninstall:

```bash

python3  -m  pip  uninstall  pre-commit  gdtoolkit
```