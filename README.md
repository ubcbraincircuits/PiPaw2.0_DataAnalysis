This repository contains the MATLAB-based analysis scripts used for the motor learning and strategy adaptation study in Huntington disease mouse models. The scripts are designed for preprocessing and analyzing the behavioral data collected from a home-cage-based lever-pulling task using the PiPaw2.0 system. The data, structured in cell arrays (one file per mouse), is deposited in the Federated Research Data Repository (FRDR).
Project Description

The project investigates motor learning deficits and adaptation strategies in zQ175 Huntington disease (HD) mouse models, using a home-cage setup. The scripts in this repository process and analyze the raw experimental data, enabling detailed statistical analysis and visualization of task performance and motor learning.

# Data

The raw data is available at FRDR and is structured as follows:

- Each file represents one mouse, containing its lever-pulling data in a cell array format.
- The data includes trial information, lever positions, task success rates, and other behavioral metrics.

# Scripts

This repository contains the following MATLAB scripts:

- Preprocessing Scripts:

        data_cleaning.m: Cleans the raw data, removing incomplete or erroneous trials.
        format_data.m: Converts raw data into a structured format for further analysis.
        extract_metrics.m: Extracts relevant metrics like hold times, success rates, and trial durations from each mouse's data.

- Analysis Scripts:

        group_analysis.m: Performs group-level statistical analysis, comparing motor learning metrics between genotypes (WT vs. zQ175).
        plot_performance.m: Generates plots visualizing the progression of motor learning, including hold time distributions and success rates over time.
        multilevel_modeling.m: Runs multilevel models to examine the effects of genotype, time, and cage on learning performance.
        correlation_analysis.m: Computes correlations between different behavioral metrics and trial performance.

- Helper Functions:
 
        calculate_hold_time.m: Calculates the hold time for each trial based on lever position.
        plot_helper.m: Utility functions for generating custom plots used in the analysis scripts.
        stat_summary.m: Summarizes the statistical outputs from various analysis scripts.

# How to Use

- Download the Data: Download the mouse data from the FRDR repository (link provided below). Ensure that each file is placed in a directory corresponding to its mouse ID.

- Run Preprocessing: Use data_cleaning.m and format_data.m to preprocess the raw data and structure it for analysis.

- Perform Analysis: After preprocessing, run the analysis scripts such as group_analysis.m or multilevel_modeling.m to analyze the motor learning data.

- Visualize Results: Use plot_performance.m to visualize learning curves, hold time distributions, and other key results.

# Data Access

The raw and preprocessed data files can be accessed at the FRDR repository:
[(https://doi.org/10.20383/103.0869)]
# Requirements

    MATLAB R2021a or later
    Statistics and Machine Learning Toolbox (for some advanced analyses)
    Plotting libraries (MATLAB built-in)

# Contact

For questions or issues related to the analysis scripts or the project, please contact:

    Daniel Ramandi
    University of British Columbia
    daniel(dot)ramandi <at> alumni.ubc.ca

# License

This project is licensed under the MIT License. See the LICENSE file for details.
