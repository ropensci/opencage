## Test environments
* local Windows install, R 3.2.4
* ubuntu 12.04 (on travis-ci), R 3.2.3
* win-builder (on appveyor-ci)

## R CMD check results
R CMD check results
0 errors | 0 warnings | 1 note
The note is:
Authors@R field gives persons with no valid roles:
  Julia Silge [rev]
* The rev role is not part of the suggested subset of MARC Code List for Relators but it is part of the MARC Code List. The role of Julia Silge in the development of this package was indeed reviewing it for rOpenSci (https://github.com/ropensci/onboarding/issues/36).
* In this article, https://journal.r-project.org/archive/2012-1/RJournal_2012-1_Hornik~et~al.pdf, it is stated that "all MARC relator codes are supported".

## Release summary

This is the first attempted CRAN release of opencage, and my first submission to CRAN.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.
