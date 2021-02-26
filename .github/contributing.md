# Contributing to opencage

First of all, thanks for considering contributing to {opencage}! 👍
We welcome bug reports and pull requests that expand and improve the functionality of {opencage} from all contributors.
This document outlines how to propose a change to {opencage}. 

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). 
By contributing to this project you agree to abide by its terms.

## How you can contribute

There are several ways you can contribute to this project. 

### Share the love ❤️

Think {opencage} is useful? 
Let others discover it, by telling them in person, via your preferred social medium, or a blog post.
Please also share your use case in our discussion forum at [discuss.ropensci.org](https://discuss.ropensci.org). 

Using {opencage} for a paper you are writing? 
Please consider [citing it](https://docs.ropensci.org/opencage/authors.html).
Get citation information for {opencage} in R with `citation(package = 'opencage')`.

### Ask a question ❓

Using {opencage} and got stuck? 
Browse the [documentation](https://docs.ropensci.org/opencage/) to see if you can find a solution. 
Still stuck? 
Post your question on our [discussion forum](https://discuss.ropensci.org) and tag it with the package name.
While we cannot offer user support, we'll try to do our best to address it, as questions often lead to better documentation or the discovery of bugs.

Want to ask a question in private? 
Email the person listed as maintainer in the `DESCRIPTION` file of this repo.
Keep in mind that private discussions over email don't help others - but of course email is totally warranted if it's a sensitive problem of any kind.

### Improve the documentation ✍

Noticed a typo on the website? 
Think a function could use a better example? 
Good documentation makes all the difference, so your help to improve it is very welcome!

Small typos or grammatical errors in documentation can be edited directly using the GitHub web interface, as long as the changes are made in the _source_ file.

This means you should

* edit a roxygen comment in a `.R` file below `R/`, not the `.Rd` files below `man/`.
* edit the `README.Rmd` file, not the `README.md` file in the package root directory.

Since we use a non-standard workflow to render the vignettes in this package, you should 

* edit the `*.Rmd.src` files in the `vignettes/` directory, not the `*.Rmd` files there.

### Reporting an issue 🐛

Using our_package and discovered a bug? 
That's annoying! 
Don't let others have the same experience and open an [issue report on GitHub](https://github.com/ropensci/opencage/issues/new) so we can fix it. 
Please illustrate the bug with a minimal working example, also known as a [reprex](https://www.tidyverse.org/help/#reprex), i.e. please provide detailed steps to reproduce the bug and any information that might be helpful in troubleshooting. The {[reprex](https://reprex.tidyverse.org/)} 📦 can help you with this. 

### Contribute code  🛠

Care to fix bugs or implement new functionality for {opencage}? 
Awesome! 👏
Before you make a substantial change to the package, it is often preferable to first discuss need and scope for the change with the author(s) of the package in an issue report. 

You should then follow the following process:

* Fork the package and clone onto your computer. 
If you haven't done this before, we recommend using `usethis::create_from_github("ropensci/opencage")`.
See the [Pull Request Helper](https://usethis.r-lib.org/articles/articles/pr-functions.html) vignette for more details on how {[usethis](https://usethis.r-lib.org/)} can assist you with contributing code via pull requests (PR), .
* Install all development dependencies with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. 
If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
* Create a Git branch for each issue you want to address. 
We recommend using `usethis::pr_init("brief-description-of-change")`.
* Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
The title of your PR should briefly describe the change; the body of your PR should contain "Fixes [#issue-number]".
* Add a bullet point to the top of `NEWS.md` describing the changes made followed by your GitHub username, and links to relevant issue(s)/PR(s).

You should also consider the following:

* Keep the changes in your PR as small and succinct as possible. 
Most importantly only address one issue per PR. 
This makes it easier for us to review and merge your PR. 
* We mostly follow the tidyverse [style guide](http://style.tidyverse.org).
You can use the {[styler](https://styler.r-lib.org/)} package to apply these styles, but please do not restyle code that has nothing to do with your PR. 
* We use {[roxygen2](https://roxygen2.r-lib.org/)}, with [Markdown syntax](https://roxygen2.r-lib.org/articles/rd-formatting.html), for documentation.
* We would prefer it if your PR also included unit tests. 
Contributions with test cases included are easier to accept and unit tests ensure that the functionality you just added will not break in the future.
We use {[testthat](https://testthat.r-lib.org/)} and {[vcr](https://docs.ropensci.org/vcr/)} for unit tests and track test coverage with [covr](https://covr.r-lib.org/) and [Codecov](https://codecov.io/).
For more information about unit tests in general and HTTP testing in particular, see the [Testing](https://r-pkgs.org/tests.html) chapter in [R packages](https://r-pkgs.org) and the [HTTP testing in R](https://books.ropensci.org/http-testing/) book, respectively.
* We use {[lintr](https://github.com/jimhester/lintr)} to check against possible coding errors and ensuring good code style. 
* We use [GitHub Actions](https://docs.github.com/en/actions) for continuous integration. 
Workflows are adapted from [r-lib/actions](https://github.com/r-lib/actions). 
Unfortunately tests requiring an API key will not run on a PR, because neither our nor your API key is available there to prevent it from leaking. 

## rOpenSci discussion forum 👄

Check out our [discussion forum](https://discuss.ropensci.org) if

* you have a question, a use case, or otherwise not a bug or feature request for the software itself.
* you think your issue requires a longer discussion.

## License 📜

{opencage} is licensed under the [GPL-2 or later](https://opensource.org/licenses/gpl-license).

## Thanks for contributing! 🙏

For more detailed info about contributing to rOpenSci, please see the [rOpenSci Community Contributing Guide](https://contributing.ropensci.org/). 
