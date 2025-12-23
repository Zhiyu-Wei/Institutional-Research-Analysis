#' Build probability matrix for exam outcomes (S1..S10) given true level (1..10)
#'
#' This helper constructs a 10x10 matrix `prob_mat` where each row k (k=1..10)
#' is a probability vector over schools 1..10 (i.e., sample.int(10, prob=...)).
#' The construction follows your original "choose b-grid, apply dbeta, normalize" steps.
#'
#' @return A 10x10 numeric matrix. Row k sums to 1.
build_prob_mat <- function() {
  
  # ---- Row 10 ----
  b <- c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.999)
  a <- dbeta(b, 10, 1)
  p10 <- round(prop.table(a), 4)
  
  # ---- Row 9 ----
  b <- c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.99995)
  a <- dbeta(b, 10, 1.6)
  p9 <- round(prop.table(a), 4)
  
  # ---- Row 8 ----
  b <- c(0.1,0.2,0.3,0.4,0.5,0.6,0.65,0.818,0.99,0.99995)
  a <- dbeta(b, 10, 3)
  p8 <- round(prop.table(a), 4)
  
  # ---- Row 7 ----
  b <- c(0.1,0.2,0.3,0.4,0.5,0.7,0.8,0.989,0.999,0.99995)
  a <- dbeta(b, 10, 3)
  p7 <- round(prop.table(a), 4)
  
  # ---- Row 6 ----
  b <- c(0.1,0.3,0.5,0.6,0.65,0.818,0.989,0.98999,0.999,0.99995)
  a <- dbeta(b, 10, 3)
  p6 <- round(prop.table(a), 4)
  
  # ---- Row 5 ----
  b <- c(0.1,0.3,0.5,0.62,0.7,0.989,0.9999,0.9999,0.9999,0.99995)
  a <- dbeta(b, 10, 3)
  p5 <- round(prop.table(a), 4)
  
  # ---- Row 4 ----
  b <- c(0.3,0.4,0.6,0.7,0.95,0.989,0.9999,0.9999,0.9999,0.99995)
  a <- dbeta(b, 10, 3)
  p4 <- round(prop.table(a), 4)
  
  # ---- Row 3 ----
  b <- c(0.4,0.6,0.7,0.965,0.979,0.9999,0.9999,0.9999,0.9999,0.99995)
  a <- dbeta(b, 10, 3)
  p3 <- round(prop.table(a), 4)
  
  # ---- Row 2 ----
  b <- c(0.6,0.7,0.955,0.985,0.999,0.9999,0.9999,0.9999,0.9999,0.99995)
  a <- dbeta(b, 10, 3)
  p2 <- round(prop.table(a), 4)
  
  # ---- Row 1 ----
  b <- c(0.818,0.6,0.975,0.9999,0.9999,0.9999,0.9999,0.9999,0.9999,0.99995)
  a <- dbeta(b, 10, 3)
  p1 <- round(prop.table(a), 4)
  
  # Stack rows: p1 is row 1, ..., p10 is row 10
  prob_mat <- do.call(rbind, list(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10))
  rownames(prob_mat) <- paste0("level", 1:10)
  colnames(prob_mat) <- paste0("S", 1:10)
  
  prob_mat
}


#' Fast simulation draws: average true level among finally admitted to a given school
#'
#' This function simulates a two-stage admission system:
#' 1) "Exam1" assignment (sampling school preference/outcome) by true ability level.
#' 2) Interview score = exam1 school index + tiny random jitter, then allocate by quota.
#' 3) Some students "retry" (take exam2) based on how far their admit is below true level.
#' 4) "Exam2" assignment for retry students, with another jitter; then fill remaining seats.
#'
#' Output is a vector of length `n_rep`, where each element is the mean true level
#' among students finally admitted to school `whichF`.
#'
#' @param x Integer in [0,100]. The first-stage (Exam1) quota for school `whichF`.
#'          All other schools have Exam1 quota 60.
#' @param whichF Integer in 1:10. Target school index (S1..S10).
#' @param n_rep Number of Monte Carlo repetitions.
#' @param prob_mat Optional 10x10 probability matrix. If NULL, will be built internally.
#'
#' @return Numeric vector length n_rep.
F_fast_draws <- function(x, whichF, n_rep = 100, prob_mat = NULL) {
  
  # ---- Input checks ----
  stopifnot(length(whichF) == 1, whichF %in% 1:10)
  stopifnot(length(x) == 1, is.finite(x), x >= 0, x <= 100)
  stopifnot(length(n_rep) == 1, is.finite(n_rep), n_rep >= 1)
  
  x <- as.integer(x)
  n_rep <- as.integer(n_rep)
  
  # Build default prob_mat if user didn't supply one
  if (is.null(prob_mat)) prob_mat <- build_prob_mat()
  
  # true_level: 100 students per level, total 1000 students
  true_level <- rep(1:10, each = 100)
  
  # Store the Monte Carlo results
  draws <- numeric(n_rep)
  
  # ---- Stage 1 quotas (Exam1) ----
  # Baseline: each school has 60 seats in stage-1, except target school gets x.
  quota <- rep(60L, 10)
  quota[whichF] <- x
  
  # Precompute slicing indices for allocating by rank
  # We allocate in order S10 -> S1 (descending school index)
  cuts1    <- cumsum(quota[10:1])
  start1   <- c(1L, head(cuts1, -1L) + 1L)
  schools1 <- 10:1
  sizes1   <- quota[10:1]
  
  for (j in seq_len(n_rep)) {
    
    # =========================================================
    # 1) Exam1 draw: for each true level k, sample a school 1..10
    #    using prob_mat[k, ] as the probability vector.
    # =========================================================
    exam1 <- integer(1000)
    for (k in 1:10) {
      idx <- which(true_level == k)
      exam1[idx] <- sample.int(
        n = 10,
        size = length(idx),
        replace = TRUE,
        prob = prob_mat[k, ]
      )
    }
    
    # =========================================================
    # Interview score: keep your original "grouped runif jitter"
    # score = s + U(0,1) rounded to 4 decimals, within each exam1 group.
    # This creates a continuous ranking without breaking group order.
    # =========================================================
    interview <- numeric(1000)
    for (s in 1:10) {
      idx <- which(exam1 == s)
      if (length(idx) > 0) {
        interview[idx] <- s + round(runif(length(idx)), 4)
      }
    }
    
    # =========================================================
    # 2) Stage-1 admission: rank by interview, fill quotas per school
    # =========================================================
    Op <- order(interview, decreasing = TRUE)
    admit1 <- integer(1000)  # 0 = not admitted in stage-1
    
    for (ii in seq_along(schools1)) {
      if (sizes1[ii] > 0) {
        ids <- Op[start1[ii]:cuts1[ii]]
        admit1[ids] <- schools1[ii]
      }
    }
    
    # =========================================================
    # 3) Decide whether a student retries (takes exam2)
    # Rule uses gap = admit1 - true_level:
    #   gap >= 0  -> no retry
    #   gap = -1  -> retry with prob 0.2
    #   gap = -2  -> retry with prob 0.6
    #   gap = -3  -> retry with prob 0.9
    #   gap <= -4 -> always retry
    #   admit1=0  -> always retry
    # =========================================================
    gap <- admit1 - true_level
    retry <- integer(1000)
    
    retry[gap >= 0] <- 0L
    
    idx1 <- which(gap == -1)
    if (length(idx1) > 0) retry[idx1] <- rbinom(length(idx1), 1, 0.2)
    
    idx2 <- which(gap == -2)
    if (length(idx2) > 0) retry[idx2] <- rbinom(length(idx2), 1, 0.6)
    
    idx3 <- which(gap == -3)
    if (length(idx3) > 0) retry[idx3] <- rbinom(length(idx3), 1, 0.9)
    
    retry[gap <= -4] <- 1L
    retry[admit1 == 0] <- 1L
    
    # =========================================================
    # 4) Seats already accepted after stage-1:
    # If retry==0, student accepts admit1; otherwise give up seat (0).
    # =========================================================
    offer <- ifelse(retry == 0, admit1, 0L)
    offer_count <- tabulate(offer, nbins = 10)
    
    # =========================================================
    # 5) Exam2 draw: only for retry==1 students
    # =========================================================
    exam2 <- rep(NA_integer_, 1000)
    take2 <- which(retry == 1)
    
    if (length(take2) > 0) {
      for (k in 1:10) {
        idx <- take2[true_level[take2] == k]
        if (length(idx) > 0) {
          exam2[idx] <- sample.int(
            n = 10,
            size = length(idx),
            replace = TRUE,
            prob = prob_mat[k, ]
          )
        }
      }
    }
    
    # Create ranking score for exam2 participants; non-participants stay -Inf
    adjust <- rep(-Inf, 1000)
    for (s in 1:10) {
      idx <- which(!is.na(exam2) & exam2 == s)
      if (length(idx) > 0) {
        adjust[idx] <- s + round(runif(length(idx)), 4)
      }
    }
    
    # =========================================================
    # 6) Stage-2 allocation: fill each school to total 100 seats
    # Remaining seats = 100 - offer_count.
    # Allocate again in order S10 -> S1 by adjust ranking.
    # =========================================================
    Op2 <- order(adjust, decreasing = TRUE)
    remain <- 100L - offer_count
    
    sizes2   <- remain[10:1]
    cuts2    <- cumsum(sizes2)
    start2   <- c(1L, head(cuts2, -1L) + 1L)
    schools2 <- 10:1
    
    admit2 <- integer(1000)
    for (ii in seq_along(schools2)) {
      if (sizes2[ii] > 0) {
        ids <- Op2[start2[ii]:cuts2[ii]]
        admit2[ids] <- schools2[ii]
      }
    }
    
    # Final admit: keep admit1 if no retry; else admit2
    final <- ifelse(retry == 0, admit1, admit2)
    
    # One replication result: mean true level among those admitted to whichF
    draws[j] <- mean(true_level[final == whichF])
  }
  
  draws
}
