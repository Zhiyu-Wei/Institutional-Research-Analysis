# Simulation 

## Step 0: Setup and environment

This step prepares the computational environment for the simulation.
Before running any Monte Carlo experiments, we load required packages, define global parameters, and initialize the core objects used throughout the analysis.

The goal of this step is **reproducibility**: after completing this setup, all subsequent steps can be executed in a deterministic and transparent way.

---

### 0.1 Required packages

The simulation relies on standard R packages for parallel computing and reproducible random number generation.

```r
library(doParallel)
library(foreach)
library(doRNG)
```
