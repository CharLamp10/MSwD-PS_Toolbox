# MSwD-PS_Toolbox
MSwD-PS is a MATLAB toolbox for computing time-varying phase synchronization (TVPS) from fMRI data using multivariate swarm decomposition (MSwD). This toolbox can be used to perform analysis, such as those presented in our paper: Lamprou, Charalampos, et al. "Robust fMRI time-varying functional connectivity analysis using multivariate swarm decomposition." Neurocomputing 642 (2025): 130404.

The toolbox has two versions, the standalone version and a version compatible with the Statistical Parametric Mapping (SPM) toolbox. The standalone version is applicable to extracted fMRI time series, either via atlas-based parcellation or via spatial Independent Component Analysis (ICA). The SPM-compatible version can be applied directly on extracted rs-fMRI time series, but it also includes a parcellation module, allowing the pipeline to be applied to volumetric fMRI data as well, in an end-to-end fashion. 

Below, we provide concrete step-by-step instructions on how to initialize and use both versions (standalone and SPM-compatible) of our software.

# Standalone Version
```matlab
addpath(genpath('C:\path\to\MSWD_Toolbox'))
mswd_ps_main;
```
Then, the window showed at the left of the figure below will pop up. By clicking "Select Files & Run", two more windows will succesively open, asking for the input files and the output directory respectively.
![Standalone Interface](plots/standalone_interface.png)

Then, a series of additional dialog windows will successively open, asking the user to define some analysis-related parameters. An overview of these windows is shown below:
![Standalone Inputs](plots/standalone_inputs2.png)

Each dialog window comes with a default option, to allow for non-familiar users to easily use the software. In multiple-choice windows the default is highlighted with light blue, while in windows asking for specific values, the default value is already pre-filled.

The first dialog window requests for a prefix that will be used for saving the derivatives of the pipeline. The second and third dialog windows ask the user to define two parameters related to Multivariate Swarm Decomposition (MSwD). For users that want to experiment with these parameters, we suggest reading our manuscript where we present the method (see above). The third window asks the users whether they want to save the decomposed fMRI time series as .mat files. The fourth window asks the users what type of analysis they want to perform with the decomposed time series. 

By clicking "TVPS", the cosine of the relative phase (CRP) will be calculated between the phases (extracted via Hilbert transform) of the most dominant oscillatory modes of all possible region pairs. This will result to a RxRxT matrix for each input file containing dynamic phase-based functional connectivity across all region pairs. The next window asks the user whether to save these CRP matrices as .mat files. Following, the users are asked to choose whether they want to perform brain state estimation using the CRP data. For more information regarding brain state estimation we suggest reading our manuscript, published in Neurocomputing. The next window asks the users whether they want to specify the number of brain states to be extracted or they want to opt for an automatic method for estimating the optimal number of brain states, based on the silhouette score. In case of the former, a new window will pop, asking the user for the number of states.

By clicking "REC", a signal reconstruction approach will take place, using differential weighting for the "global" and "local" parts of the fMRI time series. In this context, we use the term global to refer to the sum of the oscillatory modes returned by MSwD, as their frequency exists among the majority of regions, while we use the term local to refer to the residual signal. In our Neurocomputing paper we showed that using less weight for the global part results to improved functional connectivity, with respect to inter-individual variability (assessed via subject fingerprinting) and disorder classification (ASD classification). The next window asks the user to enter the reconstruction parapeter λ (the weight of the "global" part), with the default value being 0.5.

By clicking "both", both the TVPS and reconstruction analyses are performed.

# SPM-Compatible Version
The SPM-compatible version requires the SPM12 to be installed first. It can be downloaded from: https://www.fil.ion.ucl.ac.uk/spm/

Then the followng commands can be used in the MATLAB Command Window to add the required paths and initialize SPM.
```matlab
addpath C:\path\to\spm12
addpath(genpath('C:\path\to\MSWD_Toolbox'))
spm('fmri','defaults')
```

Next, in the SPM main window, click on Batch to open the Batch Editor. In the Batch Editor window, go to File -> Add Application -> spm12_parcellate.m, and click Done. Repeat this process to add the following applications: spm12_mswd.m, spm12_tvps.m, and spm12_reconstruct.m. The spm12_mswd.m, spm12_tvps.m, and spm12_reconstruct.m carry out effectively the same procedures that were described previously on the standalone version. However, the SPM-compatible version includes an additional module, the spm12_parcellate. This module enables the SPM-compatible version to be applied to volumetric data. Specifically, this module is first used to extract time series from volumetric fMRI data, and then these time series can be used exactly as described previously.


