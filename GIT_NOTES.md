# Git notes 

These are notes on common git commands and CPM conventions.

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

# TOC
1. [Branches](#branches)

    1. [Branch name convention](#branch-name-convention)

    1. [How to show existing local and remote branches](#how-to-show-existing-local-and-remote-branches)

    1. [How to switch to an existing branch](#how-to-switch-to-an-existing-branch)

    1. [How to create a new branch](#how-to-create-a-new-branch)

    1. [How to change the name of a branch](#how-to-change-the-name-of-a-branch)

    1. [How to move uncommitted changes to a new branch](#how-to-move-uncommitted-changes-to-a-new-branch)

    1. [How to copy a branch to a new branch](#how-to-copy-a-branch-to-a-new-branch)

    1. [How to update main with branch changes](#how-to-update-main-with-branch-changes)

    1. [How to update a branch with main changes](#how-to-update-a-branch-with-main-changes)

    1. [How to delete local and remote branches](#how-to-delete-local-and-remote-branches)

    1. [How to compare two branches](#how-to-compare-two-branches)

    1. [How to push a branch](#how-to-push-a-branch)
  
    1. [How to init a repo with submodules](#how-to-init-a-repo-with-submodules)


1. [Pull reguests](#pull-requests)

    1. [How to create a PR](#how-to-create-a-pr)

    1. [How to close a PR](#how-to-close-a-pr)

    1. [How to merge a remote PR](#how-to-merge-a-remote-PR)

1. [GIT config info](#git-config-info)

    1. [What URL does this repo belong to](#what-url-does-this-repo-belong-to)

------------------------------------------------------------------
## Branches

### Branch name convention

This naming convention is aligned to common practice. 

```
<user-name>/<descriptive-label>{.version}
```

Example: jeffnye/ltage_4bank

Slash is the conventional connector.

Use common sense in the number of changes contained in a branch. 
If your changes can be reviewed in less than an hour then your
PR will likely get priority.

### How to show existing local and remote branches
```
git branch       # local branches
git branch -r    # remote branches
```

### How to switch to an existing branch
```
git checkout <existing branch name>    # for a detached HEAD version
git switch   <existing branch name>    # tracking the remote branch
```

### How to create a new branch
```
git switch -c <new branch name>
```

### How to change the name of a branch
Change the name of your current local branch
```
git branch -m new-branch-name
git push origin -u new-branch-name
```
Change the name of a different local branch
```
git branch -m old-branch-name new-branch-name
git push origin -u new-branch-name
```

### How to move uncommitted changes to a new branch
```
git checkout -b <new branch name>
```

### How to copy a branch to a new branch
```
git checkout existing-branch-name
git checkout -b new-branch-name
```

### How to update main with branch changes
'A merge'
```
git checkout main
git pull origin main
git merge <branch name>
git push origin main
```

### How to update a branch with main changes
There are two methods, 
  1. rebase smashes the history making the branch tree simpler
    but loses the detail
  1. merge keeps the history

Usually option 1 for branches that have not been distributed, option 2 for 
branches that have already been shared.

Example update main, switch to branch, update branch, merge main -> branch

```
git checkout main
git pull
git checkout <branch>
git pull
git merge main
```

### How to delete local and remote branches
Do not delete the branch you are currently sitting on.
```
git branch -d <branch name>         # delete local branch
git push origin -d <branch name>    # delete a remote branch
```

### How to compare two branches
Tag is a branch name or SHA
```
git diff <tag1>..<tag2>
git diff HEAD..<tag>
```

### How to push a branch
```
git push -u origin <branch name>
```

### How to init a repo with submodules
```
<clone the repo>
<cd into the repo>
git submodule update --init --recursive
```

## Pull requests

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

### How to merge a remote PR
The situation is someone has created a PR against our repo, that person does not have write permission

Replace ID with the PR id number. 
Replace BRANCHNAME with a local branch name
```
git fetch origin pull/ID/head:BRANCHNAME
```
example:
```
cd cpm.dromajo
git fetch origin pull/3/head:kathlenemagnus/stf_improvements
git switch kathlenemagnus/stf_improvements
```

## GIT config info

### What URL does this repo belong to
```
git config --get remote.origin.url
```
