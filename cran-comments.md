## Release summary

### v0.2.2
This patch version fixes a test that caused an error on CRAN's Solaris (<https://github.com/ropensci/opencage/pull/131>, <https://www.r-project.org/nosvn/R.check/r-patched-solaris-x86/opencage-00check.html>).

## Test environments
* local x86_64-w64-mingw32/x64, R 4.0.4
* GitHub Actions <https://github.com/ropensci/opencage/actions?query=workflow%3AR-CMD-check>:
  * Ubuntu 20.04, R devel, release and oldrel
  * windows-latest, R release
  * macOS-latest, R release
* R-hub:
  * Fedora Linux, R-devel, clang, gfortran
  * Ubuntu Linux 20.04.1 LTS, R-release, GCC
  * Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* win-builder (devel)

## R CMD check results (local)

Duration: 2m 10.8s

> checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Daniel Possenriede <possenriede+r@gmail.com>'
  
  Days since last update: 4

0 errors √ | 0 warnings √ | 1 note x

## revdepcheck results

We checked 1 reverse dependency, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
