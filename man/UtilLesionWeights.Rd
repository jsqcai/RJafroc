% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/UtilLesionWeights.R
\name{UtilLesionWeights}
\alias{UtilLesionWeights}
\title{Lesion weights matrix}
\usage{
UtilLesionWeights(lesDistr)
}
\arguments{
\item{lesDistr}{The supplied lesion distribution matrix}
}
\value{
The lesion weights matrix, see \code{\link{PlotRsmOperatingCharacteristics}}
}
\description{
Computes the lesion weights  matrix, assuming equal weights.
}
\examples{
UtilLesionWeights (UtilLesionDistribution(dataset01)) # FROC data
UtilLesionWeights (UtilLesionDistribution(dataset02)) # ROC data
UtilLesionWeights (UtilLesionDistribution(datasetCadLroc)) # LROC data

}
