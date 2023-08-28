# Git notes 

These are notes on common git commands and CPM conventions.

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

# Branch name convention

The 'convention' is relaxed, just give some indication in the name 
what the branch is for, e.g. <rename.1> and not <mystuff.1>

Do not mash together a lot of changes in a branch, if your changes
can not be reviewed in less than 15 mins your PR will likely get
blocked or your code will not be reviewed which is bad.

If it becomes necessary we can decide on a more advanced naming
convention. I hopefully this is enough.

# How to create PR
<b>I have not tested this yet.</b>

You can create a PR from github.com or from the CLI
CLI: see https://git-scm.com/docs/git-request-pull

# How to create a branch and switch 
```
git switch -c <new branch name>
```
# How to push a branch
```
git push -u origin <branch name>
```

# How to merge a branch with main
```
git checkout main
git pull origin main
git merge <branch name>
git push origin main
```
