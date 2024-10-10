# Published Documentation Tree

The site folder under here is the static website published to GitHub
Pages.

The site folder is picked up by GitHub actions and published to GitHub
pages when checked-in/merged to the master branch.

## Workflow

This leads to the following workflow:

1. On your branch, issue `make docs` to create documentation tree.  If
   you want to include a current code-coverage report or static-analysis
   report then invoke `make code-coverage` or `make static-analysis`
   prior to running `make docs`.
2. Examine the resulting `_build/site` website for correctness. When
   `_build/site` is considered satisfactory, then ...
3. Issue `make docs-publish` which copies `_build/site/*` into
   `docs/site/*`. 
   
   The `docs-publish` rule does something close to the following:

``` bash
git rm -r ./docs/site/*
mkdir -p ./docs/site
cp -p -r ./_build/site/* ./docs/site/
touch ./docs/site/.nojekyll
git add -A ./docs/site
git commit -m "Publish documentation"
```
4. Then push your branch when ready.
5. Changes get peer reviewed
6. Merge to main
7. GitHub action kicks in and the site folder is published to GitHub
   pages.
