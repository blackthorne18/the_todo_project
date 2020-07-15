## On start up:

Clone current directory to where you wish to store it.
Set up alias in .bash_alias file and add todo=path_where_this_directory_is+"/main.sh".

## Quick How-to
![Alt Text](./todo_trailer.gif)

## Commands
### > todo
lists notes in active branch
### > todo wc
lists notes and completed notes in active branch
### > todo timer
can set a timer that runs and reminds you after set time
### > todo all
lists all notes from all branches
### > todo wc all
lists all notes and completed notes from all branches
### > todo ls
lists all branches (1 repesents active branch)
### > todo add \"notes\"
adds notes to current branch
### > todo del <num>
deletes notes in current branch at <num>
### > todo backup
backs up all existing to an archive directory safe from removing by todo
### > todo new <branch-name>
creates new branch
### > todo rm <branch-name>
deletes an existing branch

## Colour Scheme:
How the colour scheme reflects on your terminal depends on the inherent shell colour scheme as well. Can be edited by changing the setaf values in the first 15 lines of main.sh The number has to be between 1 and 256.
