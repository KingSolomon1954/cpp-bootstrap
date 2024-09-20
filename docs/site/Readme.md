# Published Documentation Tree

This folder is the static website published to GitHub Pages.

This folder is picked up by GitHub actions and published to 
GitHub pages when checked-in/merged to the master branch.

## Workflow

This leads to the following workflow:

1. On your branch, issue `make docs` to create documentation tree.
2. Examine the resulting `_build/site` website for correctness.
3. When the site is considered satisfactory, then issue `make
   docs-publish` which copies `_build/site/*` into
   `docs/site/*`. Actually, `docs-publish` does the following:

``` bash
git rm -r --ignore-unmatch ./docs/site/
cp -r ./_build/site/* ./docs/site/
touch ./docs/site/.nojekyll
git add -A ./docs/site
git commit -m "Website release"
```
4. Push your branch when ready.
5. Changes get peer reviewed
6. Merge to master
7. GitHub action kicks in and folder is published to GitHub pages.
