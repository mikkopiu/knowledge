# git

## Snippets

### Rebase branch on top of commits from another repo

Assumptions:

1. Local copy of `other-repo` exists
2. No access to actual remote of `other-repo`
  * With remote access, just use <https://help.github.com/articles/syncing-a-fork/>
3. Local copy of `our-repo` exists
4. No unstaged/uncommitted changes in either repo

```sh
# Move our commits to new branch
pushd
cd our-repo/
git branch our-master
git reset --hard <commit-before-our-changes-start>
git checkout our-master
popd

# Create bare repo from the other repo
pushd
mv other-repo/.git other-repo.git
cd other-repo.git/
git config --bool core.bare true
popd

# Add remote for the local copy of the other repo
pushd
cd our-repo/
git remote add other /path/to/other-repo.git

# Fetch commits from local remote
git fetch other
# and sync "fork" with current master
git merge other/master

# Rebase our changes
git checkout our-master
git rebase master
popd
```
