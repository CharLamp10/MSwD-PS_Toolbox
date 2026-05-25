# MSwD-PS_Toolbox
MSwD-PS is a MATLAB toolbox for computing time-varying phase synchronization (TVPS) from fMRI data using multivariate swarm decomposition (MSwD).

The toolbox has two versions, the standalone version and a version compatible with the Statistical Parametric Mapping (SPM) toolbox. The standalone version is applicable to extracted fMRI time series, either via atlas-based parcellation or via spatial Independent Component Analysis (ICA). The SPM-compatible version can be applied directly on extracted rs-fMRI time series, but it also includes a parcellation module, allowing the pipeline to be applied to volumetric fMRI data as well, in an end-to-end fashion. 

Below, we provide concrete step-by-step instructions on how to initialize and use both versions (standalone and SPM-compatible) of our software.

# Standalone Version
```matlab
addpath(genpath('C:\path\to\MSWD_Toolbox'))
mswd_ps_main;
```
Then, the window showed at the left of the figure below will pop up. By clicking "Select Files & Run", two more windows will succesively open, asking for the input files and the output directory respectively.
![Architecture Diagram](plots/standalone_interface.png)
