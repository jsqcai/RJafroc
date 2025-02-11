#' RSM predicted operating characteristics, ROC pdfs and different FOMs
#'    possible with FROC data
#' 
#' @description Visualize predicted ROCs, AFROCs, wAFROCs, FROCs and pdfs 
#'    (probability density functions of highest ratings, 
#'    for non-diseased and diseased cases), for up to 2 sets of search model parameters.
#'    This function is useful as an instructional tool towards understanding the RSM.
#' 
#' @param mu Array, max length 2. The mean(s) of the Gaussian distribution(s) for the 
#'    ratings of latent LLs (continuous ratings of lesions that are found by the 
#'    observer's search mechanism)
#' 
#' @param lambda Array, max length 2. The Poisson distribution \emph{intrinsic} 
#'    parameter(s), which model the random numbers of latent NLs (suspicious 
#'    regions that do not correspond to actual lesions) per case, for up to two 
#'    treatments. The corresponding \emph{physical} parameters are \code{lambda/mu}. 
#'    Two conversion functions are provided: \code{\link{UtilIntrinsic2PhysicalRSM}} and 
#'    \code{\link{UtilPhysical2IntrinsicRSM}}.
#' 
#' @param nu Array, max length 2. The binomial distribution success probability 
#'    \emph{intrinsic} parameters, which model the random numbers of latent LLs 
#'    (suspicious regions that 
#'    correspond to actual lesions) per diseased case for up to two treatments; 
#'    the corresponding \emph{physical} parameter is \code{1 - exp(nu*mu)}, 
#'    the success probability of the binomial distribution(s).
#' 
#' @param lesDistr Array, [1:maxLL,1:2]. The probability mass function of the 
#'    lesion distribution for diseased cases. The first column contains the 
#'    actual numbers of lesions per case. 
#'    The second column contains the fraction of diseased cases with the number 
#'    of lesions specified in the first column. 
#'    The second column must sum to unity.
#' 
#' @param lesionWeights Array, [1:maxLL,1:maxLL]. The weights (or clinical importances) 
#'    of the lesions. The 1st row contains the weight of the lesion on cases
#'    with one lesion only, necessarily 1; the remaining elements of the row are 
#'    \code{-Inf}. The 2nd row contains the weights of the 2 lesions on cases with 
#'    2 lesions only, the remaining elements of the row, if any, are \code{-Inf}. 
#'    Excluding the \code{-Inf}, each row must sum to 1. 
#'    The default is equal weighting, e.g., weights are 1/3, 1/3, 1/3 on row 3.
#'    This parameter is not to be confused with the lesionWeights field in an FROC
#'    dataset with enumerates the weights of lesions on individual cases. 
#' 
#' @param type The type of operating characteristic desired: can be "\code{ROC}", 
#'    "\code{AFROC}", "\code{wAFROC}", "\code{FROC}" or "\code{pdfs}" or "\code{ALL}". 
#'    The default is "\code{ALL}".
#' 
#' @param legendPosition The positioning of the legend: "\code{right}", "\code{left}", 
#'    "\code{top}" or "\code{bottom}". Use "\code{none}" to suppress the legend.
#' 
#' @param legendDirection Allows control on the direction of the legend; 
#'    \code{"horizontal"}, the default, or \code{"vertical"}
#' 
#' @param legendJustification Where to position the legend, default 
#' is bottom right corner c(0,1)
#' 
#' @param nlfRange \bold{This applies to FROC plot only}. The x-axis range, e.g., c(0,2), 
#'    for FROC plot. Default is "\code{NULL}", which means the maximum NLF range, 
#'    as determined by the data.
#' 
#' @param llfRange \bold{This applies to FROC plot only}. The y-axis range, e.g., c(0,1), 
#'    for FROC plot. Default is "\code{NULL}", which means the maximum LLF range,
#'    as determined by the data.
#' 
#' @param nlfAlpha Upper limit of the integrated area under the FROC plot. 
#'    Default is "\code{NULL}", which means the maximum NLF range is used 
#'    (i.e., lambda/mu). Attempt to integrate outside the maximum NLF will 
#'    generate an error.
#' 
#' @param myNegInf How close one approaches the end-point; the default is -3. 
#'    This is used in the code to demonstrate continuity of the slope of the 
#'    ROC at the end point; Online Appendix 17.H.3 
#'
#' 
#' @return A list of 6 elements containing six \pkg{ggplot2} objects 
#'    (ROCPlot, AFROCPlot wAFROCPlot, FROCPlot and PDFPlot) and two area measures 
#'    (each of which can have up to two elements), the area under the search 
#'    model predicted ROC curves in up to two treatments, the area under the search 
#'    model predicted AFROC curves in up to two treatments, the area under the 
#'    search model predicted wAFROC curves in up to two treatments, the area under 
#'    the search model predicted FROC curves in up to two treatments.
#' \itemize{
#' \item{\code{ROCPlot}}   {The predicted ROC plots}
#' \item{\code{AFROCPlot}}     {The predicted AFROC plots}
#' \item{\code{wAFROCPlot}}    {The predicted wAFROC plots}
#' \item{\code{FROCPlot}}  {The predicted FROC plots}
#' \item{\code{PDFPlot}}   {The predicted pdf plots}
#' \item{\code{aucROC}}    {The predicted ROC AUCs}
#' \item{\code{aucAFROC}}  {The predicted AFROC AUCs}
#' \item{\code{aucwAFROC}} {The predicted wAFROC AUCs}
#' \item{\code{aucFROC}}   {The predicted FROC AUCs}
#' }
#' 
#' @details RSM is the Radiological Search Model described in the book.
#' 
#' @note For \code{lesDistr}, the sum over the second column must equal one. 
#'    If all cases contain same number of lesions, simply supply this number instead of 
#'    the matrix. If the argument is missing, the default value 
#'    of one lesion per diseased case applies. 
#'   
#' In \code{lesionWeights}, the sum over each row (excluding \code{-Inf}) must be one. 
#'    The value \code{-Inf} should be assigned if the corresponding lesion 
#'    does not exist. Equal lesion weighting is applied if this argument is missing.
#' 
#'    For example, if the maximum number of distinct lesion configurations per case 
#'    is 3 (e.g., 1, 2 and 4, implying there are no cases with 3 lesions), the 
#'    first column of \code{lesDistr} will be c(1,2,4). The second column might be
#'    c(0.8, 0.15, 0.05), which sums to one, meaning 80\% of cases have only one 
#'    lesion, 15\% have two lesions and 5\% have three lesions. The 
#'    \code{lesionWeights} matrix will be 
#'    \code{[1:3,1:3]}, where each row will sum to one (excluding negative infinities). 
#' 
#' @import ggplot2
#' 
#' @importFrom stats integrate dbinom dnorm pnorm qnorm
#' 
#' @references
#' Chakraborty DP (2006) A search model and figure of merit for observer data acquired according to the free-response 
#' paradigm, Phys Med Biol 51, 3449-3462.
#' 
#' Chakraborty DP (2006) ROC Curves predicted by a model of visual search, Phys Med Biol 51, 3463--3482.
#'
#' Chakraborty, DP, Yoon, HJ (2008) Operating characteristics predicted by models for diagnostic tasks involving lesion localization, Med Phys, 35:2, 435.
#' 
#' Chakraborty DP (2017) \emph{Observer Performance Methods for Diagnostic Imaging - Foundations, 
#' Modeling, and Applications with R-Based Examples} (CRC Press, Boca Raton, FL). 
#' \url{https://www.crcpress.com/Observer-Performance-Methods-for-Diagnostic-Imaging-Foundations-Modeling/Chakraborty/p/book/9781482214840}
#' 
#' @examples
#' ## Following example is for mu = 2, lambda = 1, nu = 0.6, in one treatment and   
#' ## mu = 3, lambda = 1.5, nu = 0.8, in the other treatment. 20% of the diseased 
#' ## cases have a single lesion, 40% have two lesions, 10% have 3 lesions, 
#' ## and 30% have 4 lesions.  
#' lesDistr <- rbind(c(1, 0.2), c(2, 0.4), c(3, 0.1), c(4, 0.3))
#' 
#' ## On cases with one lesion the weights are 1, on cases with 2 lesions the weights
#' ## are 0.4 and 0.6, on cases with three lesions the weights are 0.2, 0.3 and 0.5, and
#' ## on cases with 4 lesions the weights are 0.3, 0.4, 0.2 and 0.1: 
#' lesionWeights <- rbind(c(1.0, -Inf, -Inf, -Inf), 
#'                        c(0.4,  0.6, -Inf, -Inf), 
#'                        c(0.2,  0.3,  0.5, -Inf), 
#'                        c(0.3,  0.4, 0.2,  0.1))
#' ret <- PlotRsmOperatingCharacteristics(mu = c(2, 3), lambda = c(1, 1.5), nu = c(0.6, 0.8),
#'    lesDistr = lesDistr, lesionWeights = lesionWeights, 
#'    legendPosition = "bottom", nlfRange = c(0, 1), llfRange = c(0, 1))
#'    print(ret$ROCPlot)
#'    print(ret$AFROCPlot)
#'    print(ret$wAFROCPlot)
#'    print(ret$FROCPlot)
#' ## the FROC plot ends at NLF = 0.5 because for both treatments the physical lambdas are 0.5.
#' 
#' @export
#' 
PlotRsmOperatingCharacteristics <- function(mu, lambda, nu, lesDistr, lesionWeights, 
                                            type = "ALL", 
                                            legendPosition = c(1,0), 
                                            legendDirection = "horizontal", 
                                            legendJustification = c(0,1),
                                            nlfRange = NULL, llfRange = NULL, nlfAlpha = NULL,
                                            myNegInf = -3){
  if (!all(c(length(mu) == length(lambda), length(mu) == length(nu))))
    stop("Parameters mu, lambda and nu have different lengths.")
  
  if (missing(lesDistr) && missing(lesionWeights)){
    lesDistr <- c(1, 1)
    dim(lesDistr) <- c(1, 2)
    lesionWeights <- 1
    dim(lesionWeights) <- c(1, 1)
  }else if (!missing(lesDistr) && missing(lesionWeights)){
    if (is.vector(lesDistr)){
      if ((length(lesDistr) == 1) && is.wholenumber(lesDistr)){
        lesDistr <- c(lesDistr, 1)
      }else if (length(lesDistr) > 2){
        stop("lesDistr must have two columns")
      }
      dim(lesDistr) <- c(1, 2)
    }
    lesionWeights <- array(-Inf, dim = c(nrow(lesDistr), max(lesDistr[ , 1])))
    for (r in 1:nrow(lesDistr)){
      lesionWeights[r, 1:lesDistr[r, 1]] <- 1 / lesDistr[r, 1]
    }
  }else{
    if (is.vector(lesDistr)){
      if ((length(lesDistr) == 1) && is.wholenumber(lesDistr)){
        lesDistr <- c(lesDistr, 1)
      }else if (length(lesDistr) > 2){
        stop("lesDistr must have two columns")
      }
      dim(lesDistr) <- c(1, 2)
      
      if (!is.vector(lesionWeights)){
        stop("lesionWeights and lesDistr must have same number of rows.")
      }else{
        dim(lesionWeights) <- c(1, length(lesionWeights))
      }
    }else if (nrow(lesDistr) != nrow(lesionWeights)){
      stop("lesionWeights and lesDistr must have same number of rows.")
      if (length(lesDistr) != 2){
        stop("lesDistr must have two columns")
      }
    }
  }
  
  for (r in 1:nrow(lesionWeights)){
    rowWeight <- lesionWeights[r, ]
    nWeight <- sum(rowWeight != -Inf)
    if (abs(sum(rowWeight[rowWeight != -Inf]) - 1.0) > 1e-6){
    #if (sum(rowWeight[rowWeight != -Inf]) != 1){ # this generated Solaris error
        errMsg <- sprintf("Line %d of lesion weights matrix should be summed up to 1.", r)
      stop(errMsg)
    }
    if (nWeight != lesDistr[r , 1]){
      errMsg <- sprintf("The number of elements in the line %d of lesion weights matrix 
                        is different the number of lesion in lesion distribution matrix.", r)
      stop(errMsg)
    }
  }
  
  plotStep <- 0.01
  zeta <- seq(from = myNegInf, to = max(mu)+5, by = plotStep) # dpc, to reduce computation time
  
  ROCPlot <- NA
  FROCPlot <- NA
  AFROCPlot <- NA
  wAFROCPlot <- NA
  PDFPlot <- NA
  
  ROCPoints <- data.frame(FPF = NULL, TPF = NULL, Treatment = NULL)
  ROCDashes <- data.frame(FPF = NULL, TPF = NULL, Treatment = NULL)
  FROCPoints <- data.frame(NLF = NULL, LLF = NULL, Treatment = NULL)
  FROCDashes <- data.frame(NLF = NULL, LLF= NULL, Treatment = NULL)
  AFROCPoints <- data.frame(FPF = NULL, LLF= NULL, Treatment = NULL)
  AFROCDashes <- data.frame(FPF = NULL, LLF= NULL, Treatment = NULL)
  wAFROCPoints <- data.frame(FPF = NULL, wLLF= NULL, Treatment = NULL)
  wAFROCDashes <- data.frame(FPF = NULL, wLLF= NULL, Treatment = NULL)
  abnPDFPoints <- data.frame(pdf = NULL, highestZSample = NULL, Treatment = NULL)
  norPDFPoints <- data.frame(pdf = NULL, highestZSample = NULL, Treatment = NULL)
  aucROC <- rep(NA, length(mu))
  aucAFROC <- aucROC
  aucwAFROC <- aucROC
  aucFROC <- aucROC
  lambdaP <- lambda
  nuP <- nu
  for (i in 1:length(mu)){
    if (nu[i] < 0 ) stop("nu must be non-negative")
    
    lambdaP[i] <- lambda[i] / mu[i]
    if (abs(nu[i] * mu[i]) <= 1e-6 ) nuP[i] <- 1e-6 else nuP[i] <- (1-exp(-nu[i] * mu[i]))
    FPF <- sapply(zeta, xROC, lambdaP = lambdaP[i])
    TPF <- sapply(zeta, yROC, mu = mu[i], lambdaP = lambdaP[i], nuP = nuP[i], lesDistr = lesDistr)
    NLF <- sapply(zeta, xFROC, lambdaP = lambdaP[i])
    LLF <- sapply(zeta, yFROC, mu = mu[i], nuP = nuP[i])
    
    maxFPF <- xROC(-20, lambdaP[i])
    if(type == "ALL" || type == "ROC"){
      ROCPoints <- rbind(ROCPoints, data.frame(FPF = FPF, TPF = TPF, Treatment = as.character(i)))
      ROCDashes <- rbind(ROCDashes, data.frame(FPF = c(FPF[1], 1), TPF = c(TPF[1], 1), Treatment = as.character(i)))
      maxTPF <- yROC(-20, mu[i], lambdaP[i], nuP[i], lesDistr)
      AUC <- integrate(intROC, 0, maxFPF, mu = mu[i], lambdaP = lambdaP[i], nuP = nuP[i], lesDistr =lesDistr)$value
      aucROC[i] <- AUC + (1 + maxTPF) * (1 - maxFPF) / 2
    }
    
    if(type == "ALL" || type == "FROC"){
      FROCPoints <- rbind(FROCPoints, data.frame(NLF = NLF, LLF = LLF, Treatment = as.character(i)))
      if (is.null(nlfAlpha)){
        maxNLF <- max(NLF)
        aucFROC[i] <- integrate(intFROC, 0, maxNLF, mu= mu[i], lambdaP = lambdaP[i], nuP = nuP[i])$value
      }else{
        maxNLF <- max(NLF)
        if (nlfAlpha <= maxNLF){
          aucFROC[i] <- integrate(intFROC, 0, nlfAlpha, mu= mu[i], lambdaP = lambdaP[i], nuP = nuP[i])$value
        }else{
          stop("nlfAlpha cannot be greater than the maximum of NLF.")
        }
      }
    }
    
    if(type == "ALL" || type == "AFROC"){
      AFROCPoints <- rbind(AFROCPoints, data.frame(FPF = FPF, LLF = LLF, Treatment = as.character(i)))
      AFROCDashes <- rbind(AFROCDashes, data.frame(FPF = c(FPF[1], 1), LLF = c(LLF[1], 1), 
                                                   Treatment = as.character(i)))
      maxLLF <- yFROC(-20, mu[i], nuP[i])
      AUC <- integrate(intAFROC, 0, maxFPF, mu = mu[i], lambdaP = lambdaP[i], nuP = nuP[i])$value
      aucAFROC[i] <- AUC + (1 + maxLLF) * (1 - maxFPF) / 2
    }
    
    if(type == "ALL" || type == "wAFROC"){
      wLLF <- sapply(zeta, ywAFROC, mu = mu[i], nuP = nuP[i], lesDistr = lesDistr, lesionWeights = lesionWeights)
      wAFROCPoints <- rbind(wAFROCPoints, data.frame(FPF = FPF, wLLF = wLLF, 
                                                     Treatment = as.character(i)))
      wAFROCDashes <- rbind(wAFROCDashes, data.frame(FPF = c(FPF[1], 1), wLLF = c(wLLF[1], 1), Treatment = as.character(i)))
      maxWLLF <- ywAFROC(-20, mu[i], nuP[i], lesDistr, lesionWeights)
      AUC <- integrate(intwAFROC, 0, maxFPF, mu = mu[i], lambdaP = lambdaP[i], nuP = nuP[i], lesDistr, lesionWeights)$value
      aucwAFROC[i] <- AUC + (1 + maxWLLF) * (1 - maxFPF) / 2
    }
    
    if(type == "ALL" || type == "pdfs"){
      deltaFPF <- FPF[1:(length(FPF) - 1)] - FPF[2:length(FPF)]  
      if(type == "ALL" || type == "pdfs"){     
        pdfNor <- deltaFPF / plotStep
        norPDFPoints <- rbind(norPDFPoints, 
                              data.frame(pdf = pdfNor[pdfNor > 1e-6], highestZSample = zeta[-1][pdfNor > 1e-6], 
                                         Treatment = as.character(i), class = "non-diseased"))
        deltaTPF <- TPF[1:(length(TPF) - 1)] - TPF[2:length(TPF)]
        pdfAbn <- deltaTPF / plotStep
        abnPDFPoints <- rbind(abnPDFPoints, 
                              data.frame(pdf = pdfAbn[pdfAbn > 1e-6], highestZSample = zeta[-1][pdfAbn > 1e-6], 
                                         Treatment = as.character(i), class = "diseased"))
      }
    }
  }
  
  if(type == "ALL" || type == "ROC") {
    ROCPlot <- with(ROCPoints, {
      ggplot(data = ROCPoints) + 
        geom_line(aes(x = FPF, y = TPF, color = Treatment))  +       
        geom_line(data = ROCDashes, aes(x = FPF, y = TPF, color = Treatment), linetype = 2) +       
        theme(legend.position = legendPosition, legend.direction = legendDirection, legend.justification = c(1, 0)) 
    })
  }
  
  if(type == "ALL" || type == "FROC"){
    FROCPlot <- with(FROCPoints, {
      ggplot(data = FROCPoints) + 
        geom_line(aes(x = NLF, y = LLF, color = Treatment))  +       
        scale_x_continuous(expand = c(0, 0), limits = nlfRange) + 
        scale_y_continuous(expand = c(0, 0), limits = llfRange) + 
        theme(legend.position = legendPosition, legend.direction = legendDirection, legend.justification = c(1, 0)) 
    })
  }
  
  if(type == "ALL" || type == "AFROC"){
    AFROCPlot <- with(AFROCPoints, {
      ggplot(data = AFROCPoints) + 
        geom_line(aes(x = FPF, y = LLF , color = Treatment)) + 
        geom_line(data = AFROCDashes, aes(x = FPF, y = LLF, color = Treatment), linetype = 2) +       
        theme(legend.position = legendPosition, legend.direction = legendDirection, legend.justification = c(1, 0)) 
    }
    )
  }
  
  if(type == "ALL" || type == "wAFROC"){
    wAFROCPlot <- with(wAFROCPoints, {
      ggplot(data = wAFROCPoints) + 
        geom_line(aes(x = FPF, y = wLLF , color = Treatment)) + 
        geom_line(data = wAFROCDashes, aes(x = FPF, y = wLLF, color = Treatment), linetype = 2) +       
         theme(legend.position = legendPosition, legend.direction = legendDirection, legend.justification = c(1, 0)) 
    })
  }
  
  if(type == "ALL" || type == "pdfs"){
    if (legendPosition == "top" || legendPosition == "bottom"){
      legendDirection = "horizontal"
    }else{
      legendDirection = "vertical"
    }
    PDFPoints <- rbind(norPDFPoints, abnPDFPoints)
    PDFPlot <- with(PDFPoints, {
      ggplot(data = PDFPoints, 
             aes(x = highestZSample, y = pdf, color = Treatment, linetype = class)) + 
        geom_line()  + theme(legend.position = legendPosition, legend.box = legendDirection) + 
        labs(x = "Highest Z Sample") 
    })
  }
  
  return(list(
    ROCPlot = ROCPlot,
    AFROCPlot = AFROCPlot,
    wAFROCPlot = wAFROCPlot,
    FROCPlot = FROCPlot,
    PDFPlot = PDFPlot,
    aucROC = aucROC,
    aucAFROC = aucAFROC,
    aucwAFROC = aucwAFROC,
    aucFROC = aucFROC
  ))
}



myPlot <- function(dataPoints, dashedPoints, x, y, 
                   legendPosition, legendDirection, legendJustification) {
  ret <- with(dataPoints, {
    ggplot(data = dataPoints) + 
      geom_line(aes(x = x, y = y , color = Treatment)) + 
      geom_line(data = dashedPoints, aes(x = x, y = y, color = Treatment), linetype = 2) +       
       theme(legend.position = legendPosition, legend.direction = legendDirection, 
            legend.justification = legendJustification) 
  })
  return(ret)
}



xFROC <- function(zeta, lambdaP){
  # returns NLF, the abscissa of FROC curve
  NLF <- lambdaP * (1 - pnorm(zeta))
  return(NLF)
}

yFROC <- function(zeta, mu, nuP){
  # returns LLF, the ordinate of FROC, AFROC curve
  LLF <- nuP * (1 - pnorm(zeta - mu))
  return(LLF)
}

intFROC <- function(NLF, mu, lambdaP, nuP){
  zeta <- qnorm(1 - NLF / lambdaP)
  LLF <- yFROC(zeta, mu, nuP)
  return(LLF)
}

intAFROC <- function(FPF, mu, lambdaP, nuP){
  # returns LLF, the ordinate of AFROC curve; takes FPF as the variable. 
  # AUC is calculated by integrating this function in terms of FPF
  tmp <- 1 / lambdaP * log(1 - FPF) + 1
  tmp[tmp < 0] <- pnorm(-20)
  zeta <- qnorm(tmp)
  LLF <- yFROC(zeta, mu, nuP)
  return(LLF)
}

ywAFROC <- function(zeta, mu, nuP, lesDistr, lesionWeights){
  # returns wLLFL, the ordinate of wAFROC curve
  fl <- lesDistr[, 2] / sum(lesDistr[, 2])
  wLLF <- 0
  for (L in 1:nrow(lesDistr)){
    nLesion <- lesDistr[L, 1] 
    # nLesion is the first element in the row L of lesDistr, 
    # which is the number of lesions for this lesion weights distributions condition
    wLLFTmp <- 0
    for (l in 1:nLesion){
      # l is the number of sucesses with number of lesions nLesion
      wLLFTmp <- wLLFTmp + sum(lesionWeights[L, 1:l]) * dbinom(l, nLesion, nuP) * (1 - pnorm(zeta - mu))
      
    }
    wLLF <- wLLF + fl[L] * wLLFTmp
  }
  return(wLLF)
}

intwAFROC <- function(FPF, mu, lambdaP, nuP, lesDistr, lesionWeights){
  # returns wLLF, the ordinate of AFROC curve; takes FPF as the variable. 
  # AUC is calculated by integrating this function in terms of FPF
  tmp <- 1 / lambdaP * log(1 - FPF) + 1
  tmp[tmp < 0] <- pnorm(-20)
  zeta <- qnorm(tmp)
  wLLF <- sapply(zeta, ywAFROC, mu = mu, nuP = nuP, lesDistr, lesionWeights)
  return(wLLF)
}

is.wholenumber <- function(x)  round(x) == x


xROC <- function (zeta, lambdaP){
  return (1 - exp( (-lambdaP / 2) + 0.5 * lambdaP * erfcpp(zeta / sqrt(2))))
}

xROCVect <- function(zeta, lambdaP) {
    FPF = 1 - exp( (-lambdaP / 2) + 0.5 * lambdaP * erfcpp(zeta / sqrt(2.0)))
  return (FPF);
}

# R-only implementation of erf function
erf_R <- function(x){
 return (2 * pnorm(sqrt(2) * x) - 1)
}
