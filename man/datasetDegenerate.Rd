% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datasets.R
\docType{data}
\name{datasetDegenerate}
\alias{datasetDegenerate}
\title{Simulated degenerate ROC dataset (for testing purposes)}
\format{A list with 8 elements:
\itemize{
\item{\code{NL}}{ Ratings array [1, 1, 1:15, 1], of false positives, FPs}
\item{\code{LL}}{ Ratings array [1, 1, 1:10, 1], of true positives, TPs}
\item{\code{lesionNum}}{ array [1:10], number of lesions per diseased case, all set to 1}
\item{\code{lesionID}}{ array [1:10, 1], labels of lesions on diseased cases, all set to 1}
\item{\code{lesionWeight}}{ array [1:10, 1], weights (or clinical importance) of lesions, all set to 1}
\item{\code{dataType}}{ "ROC", the data type}
\item{\code{modalityID}}{ "1", treatment label}
\item{\code{readerID}}{ "1", reader label}
}}
\usage{
datasetDegenerate
}
\description{
A simulated degenerated dataset. A degenerate dataset is defined as one with
no interior operating points on the ROC plot. Such data tend to be observed with expert level 
radiologists. This dataset is used to illustrate the robustness of two fitting models, namely
CBM and RSM. The widely used binormal model and PROPROC fail on such datasets.
}
\examples{
str(datasetDegenerate)


}
\keyword{datasets}
