## Release summary

### v0.2.1
* Fixed two URLs, one of which was rejected on the v0.2.0 submission.

### v0.2.0 (unreleased)
* Rewrite of the package, see NEWS.md for details.
* Change of maintainer:
  * New Maintainer: Daniel Possenriede <possenriede+r@gmail.com>
  * Old maintainer: Maëlle Salmon <maelle.salmon@yahoo.se>

## Test environments
* local x86_64-w64-mingw32/x64 install, R 4.0.3
* GitHub Actions <https://github.com/ropensci/opencage/actions?query=workflow%3AR-CMD-check>:
  * Ubuntu 20.04, R devel, release and oldrel
  * windows-latest, R release
  * macOS-latest, R release
* R-hub:
  * Fedora Linux, R-devel, clang, gfortran
  * Ubuntu Linux 20.04.1 LTS, R-release, GCC
  * Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* win-builder (devel)

## R CMD check results

Duration: 2m 1.9s

> checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Daniel Possenriede <possenriede+r@gmail.com>'
  
  New maintainer:
    Daniel Possenriede <possenriede+r@gmail.com>
  Old maintainer(s):
    Maëlle Salmon <maelle.salmon@yahoo.se>

0 errors √ | 0 warnings √ | 1 note x

## revdepcheck results

We checked 1 reverse dependency, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
