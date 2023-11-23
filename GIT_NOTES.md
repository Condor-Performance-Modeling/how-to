# Git notes 

These are notes on common git commands and CPM conventions.

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

# TOC
1. [Branch name convention](#branch-name-convention)

1. [How to create a PR](#how-to-create-a-pr)

1. [How to close a PR](#how-to-close-a-pr)

1. [How to switch to an existing branch](#how-to-switch-to-an-existing-branch)

1. [How to create a branch and switch](#how-to-create-a-branch-and-switch)

1. [How to create a branch and move uncommited changes to that branch](#how-to-create-a-branch-and-move-uncommited-changes-to-that-branch)

1. [How to push a branch](#how-to-push-a-branch)

1. [How to merge a branch with main](#how-to-merge-a-branch-with-main)

1. [How to show branches](#how-to-show-branches)

1. [How to delete branches](#how-to-delete-branches)

1. [How to merge main/master changes into a branch](#how-to-merge-main-master-changes-into-a-branch)

1. [What URL does this repo belong to](#what-url-does-this-repo-belong-to)

------------------------------------------------------------------
### Branch name convention

The naming 'convention' is aligned to common practice. 

```
<user-name>/<descriptive-label>{.version}
```

Example: jeffnye-gh/ltage_4bank.1

Slash is the conventional connector.  The {.version} is optional.

Use common sense in the number of changes contained in a branch. 
If your changes can be reviewed in less than an hour then your
PR will likely get priority.

### How to create a PR
```
make your changes in a branch
commit to that branch
create the pull request using web (or CLI, this assumes web)
On the Open pull request page select reviewers (on the right)
hit "Create pull request"
email/slack any other reviewer, add Jeff as a minimum
```

### How to close a PR
```
Your reviewers will request changes - make any corrections
Your reviewers will give an all clear or similar, reviewers please do this as a comment for tracking
Merge your PR
```
If someone does not respond in a reasonable time, vacations, etc, use common sense on when to merge.


### How to switch to an existing branch
```
git checkout <existing branch name>    # for a detached HEAD version
git switch   <existing branch name>    # tracking the remote branch
```
### How to create a branch and switch 
```
git switch -c <new branch name>
```
### How to create a branch and move uncommited changes to that branch
```
git checkout -b <new branch name>
```
### How to push a branch
```
git push -u origin <branch name>
```
### How to merge a branch with main
```
git checkout main
git pull origin main
git merge <branch name>
git push origin main
```
### How to show branches
```
git branch       # local branches
git branch -r    # remote branches
```
### How to delete branches
Do not delete the branch you are currently sitting on.
```
git branch -d <branch name>         # delete local branch
git push origin -d <branch name>    # delete a remote branch
```
### How to merge main/master changes into a branch
There are two methods, 

  1. rebase smashes the history making the branch tree simpler
    but loses the detail
  1. merge keeps the history

Usually option 1 for branches that have not been distributed, option 2 for branches that have been shared.

Example update main, switch to branch, update branch, merge main -> branch

```
git checkout main
git pull
git checkout <branch>
git pull
git merge main
```
### What URL does this repo belong to
```
git config --get remote.origin.url
```
