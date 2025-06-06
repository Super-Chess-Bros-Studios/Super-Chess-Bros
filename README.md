# Super-Chess-Bros
The super cool awesome 2D platform fighter chess adaption made in Godot

1. Prerequisites
Make sure you have the following installed on your machine:

Python 3.7 or newer (https://www.python.org/downloads/)


2. Clone the Repository
Open your terminal (Git Bash on Windows or Terminal on macOS/Linux) and run:

git clone https://github.com/MasonHall9987/Super-Chess-Bros
cd your-repo


3. Install Python Dependencies and Set Up Git Hooks
python3 -m pip install --user --upgrade pre-commit
python3 -m pip install --user --upgrade "gdtoolkit==4.*
python3 -m pre_commit install


4. Verify Installation
python3 -m pre_commit run --all-files


5. Usage
Now, every time you make a Git commit, the pre-commit hook will automatically:

Lint your GDScript files using gdlint

Format your GDScript files using gdformat

If linting errors are found, the commit will be blocked until you fix them.


6. Additional Notes
To update the tooling later, run:

python3 -m pip install --user --upgrade pre-commit gdtoolkit
To uninstall:

python3 -m pip uninstall pre-commit gdtoolkit
