#!/usr/bin/env nextflow

/*
========================================================================================
    Data Science Workflow Pipeline
========================================================================================
    Author: abhi18av
    Date: 2025-06-11
    Description: Comprehensive data science pipeline with modular subworkflows
*/

nextflow.enable.dsl=2

// Define default parameters
params.projectDir = "$projectDir"
params.dataDir = "$projectDir/data"
params.resultsDir = "$projectDir/results"
params.reportsDir = "$projectDir/reports"
params.rawData = "$params.dataDir/raw"
params.processedData = "$params.dataDir/processed"
params.featureData = "$params.dataDir/features"
params.modelDir = "$params.resultsDir/models"

// Log parameters
log.info """\
    ==============================================
    DATA SCIENCE PIPELINE - v1.0
    ==============================================
    Project Directory : ${params.projectDir}
    Data Directory    : ${params.dataDir}
    Results Directory : ${params.resultsDir}
    Started by        : abhi18av
    Date/Time         : 2025-06-11 20:23:47 UTC
    ==============================================
    """
    .stripIndent()

/*
========================================================================================
    01-DATA SUBWORKFLOW - Data Extraction, Transformation, Cleaning and Storage
========================================================================================
*/
workflow DATA {
    take:
        raw_data_source // Path, URL, or DB connection info

    main:
        // Data Extraction (011)
        extracted_data = DATA_EXTRACTION(raw_data_source)

        // Data Loading (012)
        loaded_data = DATA_LOADING(extracted_data)

        // Data Inspection (013)
        inspection_report = DATA_INSPECTION(loaded_data)

        // Data Cleaning (014)
        cleaned_data = DATA_CLEANING(loaded_data)

        // Data Validation (015)
        validation_report = DATA_VALIDATION(cleaned_data)

        // Data Transformation (016)
        transformed_data = DATA_TRANSFORMATION(cleaned_data)

        // Data Saving (017)
        saved_data_path = DATA_SAVING(transformed_data)

    emit:
        data = saved_data_path
        inspection = inspection_report
        validation = validation_report
}


/*
========================================================================================
    PROCESS DEFINITIONS
========================================================================================
*/

// 01-DATA Processes
process DATA_EXTRACTION {
    publishDir "${params.dataDir}/raw", mode: 'copy'

    input:
    val source

    output:
    path "extracted_data.csv"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/011_data_extraction/extract.py \
        --source "${source}" \
        --output extracted_data.csv
    """
}

process DATA_LOADING {
    input:
    path data

    output:
    path "loaded_data.csv"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/012_data_loading/load.py \
        --input ${data} \
        --output loaded_data.csv
    """
}

process DATA_INSPECTION {
    publishDir "${params.reportsDir}/data", mode: 'copy'

    input:
    path data

    output:
    path "inspection_report.html"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/013_data_inspection/inspect.py \
        --input ${data} \
        --output inspection_report.html
    """
}

process DATA_CLEANING {
    input:
    path data

    output:
    path "cleaned_data.csv"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/014_data_cleaning/clean.py \
        --input ${data} \
        --output cleaned_data.csv
    """
}

process DATA_VALIDATION {
    publishDir "${params.reportsDir}/data", mode: 'copy'

    input:
    path data

    output:
    path "validation_report.json"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/015_data_validation/validate.py \
        --input ${data} \
        --output validation_report.json
    """
}

process DATA_TRANSFORMATION {
    input:
    path data

    output:
    path "transformed_data.csv"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/016_data_transformation/transform.py \
        --input ${data} \
        --output transformed_data.csv
    """
}

process DATA_SAVING {
    publishDir "${params.processedData}", mode: 'copy'

    input:
    path data

    output:
    path "final_data.parquet"

    script:
    """
    python ${params.projectDir}/notebooks/01-data/017_data_saving/save.py \
        --input ${data} \
        --output final_data.parquet
    """
}


/*
========================================================================================
    02-EXPLORATION SUBWORKFLOW - Exploratory Data Analysis
========================================================================================
*/

workflow EXPLORATION {
    take:
        data // Path to processed data

    main:
        // Descriptive Statistics (021)
        desc_stats = DESCRIPTIVE_STATISTICS(data)

        // Univariate Analysis (022)
        univariate_results = UNIVARIATE_ANALYSIS(data)

        // Bivariate Analysis (023)
        bivariate_results = BIVARIATE_ANALYSIS(data)

        // Multivariate Analysis (024)
        multivariate_results = MULTIVARIATE_ANALYSIS(data)

        // Outlier Detection (025)
        outliers = OUTLIER_DETECTION(data)

        // Missing Value Analysis (026)
        missing_analysis = MISSING_VALUE_ANALYSIS(data)

        // Visualization (027)
        visualization = VISUALIZATION(
            data,
            univariate_results,
            bivariate_results,
            multivariate_results,
            outliers,
            missing_analysis
        )

    emit:
        stats = desc_stats
        univariate = univariate_results
        bivariate = bivariate_results
        multivariate = multivariate_results
        outliers = outliers
        missing = missing_analysis
        visuals = visualization
}

/*
========================================================================================
    03-ANALYSIS SUBWORKFLOW - Hypothesis Testing and Statistical Analysis
========================================================================================
*/
workflow ANALYSIS {
    take:
        data
        exploration_results

    main:
        // Hypothesis Testing (031)
        hypothesis_results = HYPOTHESIS_TESTING(data, exploration_results.stats)

        // Correlation Analysis (032)
        correlation_results = CORRELATION_ANALYSIS(data)

        // Group Comparison (033)
        group_comparison = GROUP_COMPARISON(data)

        // Time Series Analysis (034)
        time_series_results = TIME_SERIES_ANALYSIS(data)

        // Spatial Analysis (035)
        spatial_results = SPATIAL_ANALYSIS(data)

        // Network Analysis (036)
        network_results = NETWORK_ANALYSIS(data)

        // Statistical Modeling (037)
        statistical_models = STATISTICAL_MODELING(data)

    emit:
        hypothesis = hypothesis_results
        correlation = correlation_results
        groups = group_comparison
        time_series = time_series_results
        spatial = spatial_results
        network = network_results
        stat_models = statistical_models
}

/*
========================================================================================
    04-FEAT_ENG SUBWORKFLOW - Feature Engineering
========================================================================================
*/
workflow FEATURE_ENGINEERING {
    take:
        data
        analysis_results

    main:
        // Feature Creation (041)
        created_features = FEATURE_CREATION(data, analysis_results)

        // Feature Transformation (042)
        transformed_features = FEATURE_TRANSFORMATION(created_features)

        // Feature Selection (043)
        selected_features = FEATURE_SELECTION(transformed_features)

        // Feature Scaling (044)
        scaled_features = FEATURE_SCALING(selected_features)

        // Dimensionality Reduction (045)
        reduced_features = DIMENSIONALITY_REDUCTION(scaled_features)

    emit:
        features = reduced_features
        feature_metadata = FEATURE_METADATA(reduced_features)
}

/*
========================================================================================
    05-MODELS SUBWORKFLOW - Model Training and Evaluation
========================================================================================
*/
workflow MODELING {
    take:
        features
        feature_metadata

    main:
        // Baseline Models (051)
        baseline_results = BASELINE_MODELS(features)

        // Advanced Models (052)
        advanced_results = ADVANCED_MODELS(features)

        // Hyperparameter Tuning (053)
        tuned_models = HYPERPARAMETER_TUNING(features, advanced_results)

        // Cross Validation (053)
        cv_results = CROSS_VALIDATION(features, tuned_models)

        // Model Evaluation (054)
        evaluation_results = MODEL_EVALUATION(features, cv_results)

        // Model Selection (055)
        selected_model = MODEL_SELECTION(evaluation_results)

    emit:
        model = selected_model
        evaluation = evaluation_results
}

/*
========================================================================================
    06-INTERPRETATION SUBWORKFLOW - Model Interpretation
========================================================================================
*/
workflow INTERPRETATION {
    take:
        model
        features
        feature_metadata

    main:
        // Feature Importance (061)
        importance = FEATURE_IMPORTANCE(model, features, feature_metadata)

        // Partial Dependence (062)
        pdp = PARTIAL_DEPENDENCE(model, features)

        // SHAP Explainer (063)
        shap_values = SHAP_EXPLAINER(model, features)

        // Domain Validation (064)
        domain_validation = DOMAIN_VALIDATION(model, importance, pdp, shap_values)

        // ROI Analysis (065)
        roi = ROI_ANALYSIS(model, domain_validation)

        // Limitation Analysis (066)
        limitations = LIMITATION_ANALYSIS(model, domain_validation)

        // Risk Assessment (067)
        risks = RISK_ASSESSMENT(model, limitations)

        // Implementation Strategy (068)
        implementation = IMPLEMENTATION_STRATEGY(model, roi, risks)

    emit:
        importance = importance
        pdp = pdp
        shap = shap_values
        roi = roi
        implementation = implementation
}

/*
========================================================================================
    07-REPORTS SUBWORKFLOW - Reporting and Visualization
========================================================================================
*/
workflow REPORTS {
    take:
        model
        evaluation
        interpretation

    main:
        // Executive Summary (071)
        summary = EXECUTIVE_SUMMARY(model, evaluation, interpretation)

        // Visual Storytelling (072)
        story = VISUAL_STORYTELLING(model, evaluation, interpretation)

        // Notebook Slides (073)
        slides = NOTEBOOK_SLIDES(model, evaluation, interpretation)

        // Appendices (074)
        appendices = APPENDICES(model, evaluation, interpretation)

    emit:
        summary = summary
        story = story
        slides = slides
        appendices = appendices
}

/*
========================================================================================
    08-DEPLOY SUBWORKFLOW - Model Deployment
========================================================================================
*/
workflow DEPLOYMENT {
    take:
        model
        implementation

    main:
        // Model Packaging (081)
        package = MODEL_PACKAGING(model)

        // Dockerization (082)
        docker = DOCKERIZATION(package)

        // CI/CD Pipelines (083)
        cicd = CI_CD_PIPELINES(docker)

        // API Deployment (084)
        api = API_DEPLOYMENT(docker)

        // Monitoring (085)
        monitoring = MONITORING(api)

    emit:
        api = api
        monitoring = monitoring
}


/*
========================================================================================
    MAIN WORKFLOW
========================================================================================
*/
workflow {
    // Define input
    raw_data_ch = Channel.value(params.rawData)

    // Execute stage 01 - Data
    DATA(raw_data_ch)

    // Execute stage 02 - Exploration
    EXPLORATION(DATA.out.data)

    // Execute stage 03 - Analysis
    ANALYSIS(DATA.out.data, EXPLORATION.out)

    // Execute stage 04 - Feature Engineering
    FEATURE_ENGINEERING(DATA.out.data, ANALYSIS.out)

    // Execute stage 05 - Modeling
    MODELING(FEATURE_ENGINEERING.out.features, FEATURE_ENGINEERING.out.feature_metadata)

    // Execute stage 06 - Interpretation
    INTERPRETATION(
        MODELING.out.model,
        FEATURE_ENGINEERING.out.features,
        FEATURE_ENGINEERING.out.feature_metadata
    )

    // Execute stage 07 - Reports
    REPORTS(
        MODELING.out.model,
        MODELING.out.evaluation,
        INTERPRETATION.out
    )

    // Execute stage 08 - Deployment
    DEPLOYMENT(
        MODELING.out.model,
        INTERPRETATION.out.implementation
    )
}
