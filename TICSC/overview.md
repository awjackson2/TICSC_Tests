
### Quick Overview

TI-CSC/               <project_dir>/
│                     ├── Subjects/
├── analyzer/         │   ├── m2m_<subject_id>/
├── optimizer/        │   └── leadfield_<subject_id>/
└── README.md         └── Simulations/
                      |    ├── sim_<subject_id>/
                      |    └── opt_<subject_id>/
                      |__ utils 


### Toolbox & Scripts

TI-CSC/
│
├── analyzer/
│   ├── base-niftis/              # Base NIfTI files for ROI analysis
│   ├── field-analysis/           # Scripts for analyzing fields within meshes
│   │   ├── gm_extract.py         # Script to extract gray matter (GM) mesh from the whole-brain mesh
│   │   ├── main-mTI.sh           # Main script for running multipolar TI simulations
│   │   ├── main-TI.sh            # Main script for running unipolar TI simulations
│   │   ├── mesh2nii_loop.sh      # Script to convert meshes to NIfTI files
│   │   ├── montage_list.json     # JSON file containing electrode montages
│   │   ├── mTI.py                # Python script for multipolar TI simulation
│   │   ├── roi_list.json         # JSON file listing ROIs for analysis
│   │   ├── screenshot.sh         # Script to generate screenshots of the simulations
│   │   ├── sphere-analysis.sh    # Script for spherical ROI analysis
│   │   ├── start-ana.sh          # Script to start the analysis pipeline
│   │   └── TI.py                 # Python script for running TI simulations
│
├── optimizer/
│   ├── base-niftis/              # Base NIfTI files for optimization process
│   ├── field-analysis/           # Scripts for mesh processing and analysis
│   │   ├── electrode-selector.py # Script for selecting electrode configurations
│   │   ├── leadfield.py          # Script for generating leadfields
│   │   ├── mesh-selector.sh      # Script to select mesh files for processing
│   │   ├── nii2msh_convert.sh    # Script to convert NIfTI files back to mesh format
│   │   ├── roi-analyzer.py       # Python script to analyze ROI data
│   │   ├── roi-creator.py        # Python script to create or modify ROIs
│   │   ├── start-opt.sh          # Script to start the optimization pipeline
│   │   ├── sur2vol.py            # Script to convert surface field data to volumetric NIfTI
│   │   ├── ti_sim.py             # Script to run TI simulations for optimization
│   │   ├── update_output_csv.py  # Script to update output CSV files with new analysis results
│   │   └── view-nifti.sh         # Script to view NIfTI files
│
├── utils/
│   └── # General utility scripts
│
├── .gitignore                     # Git ignore file
├── license.txt                    # License file for the toolbox
├── overview.md                    # Overview of the toolbox and pipelines
└── README.md                      # Main readme for the toolbox


### local project directory

<project_dir>/
│
├── original_MRIs/                 # Original MRI files for different subjects
│   ├── <subject>.nii              # Subject-specific MRI files (e.g., T1-weighted)
│
├── Simulations/
│   ├── sim_<subject_id>/          # Simulation data for each subject
│   │   ├── FEM/                   # Finite Element Method simulation results
│   │   ├── GM_mesh/               # Processed gray matter mesh files
│   │   ├── nifti/                 # NIfTI files derived from meshes
│   │   ├── ROI_analysis/          # Results from ROI analysis
│   │   ├── screenshots/           # Screenshots of simulations for quick viewing
│   │   └── Whole-Brain-mesh/      # Whole-brain mesh files
│   ├── opt_<subject_id>/          # Optimization results for each subject
│
└── Subjects/
    ├── m2m_<subject_id>/          # Preprocessed subject data
    │   ├── T1.nii.gz              # Subject’s T1-weighted MRI
    │   ├── eeg_positions/         # EEG cap positions
    │   ├── DTI_coregT1_tensor.nii.gz  # DTI tensor file
    │   ├── ROIs/                  # ROI files for the subject
    │   └── <other_files>/         # Any additional files related to the subject
    ├── leadfield_<subject_id>/    # Leadfield data for each subject
    │   ├── leadfield_gm/          # Leadfield data for gray matter
    │   ├── leadfield_vol/         # Leadfield data for volume
    └── <additional_subjects>/     # Additional data for other subjects
