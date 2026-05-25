#!/usr/bin/env nextflow

/*
 * Data Processing Pipeline with Nextflow
 * 
 * This pipeline demonstrates a typical data science workflow:
 * 1. Data validation
 * 2. Data cleaning
 * 3. Feature engineering
 * 4. Data quality assessment
 * 5. Export processed data
 */

// Pipeline parameters
params.input = '../data/01_raw/*.csv'
params.output_dir = '../data/02_processed'
params.config = '../pipelines/configs/pipeline-config.yaml'
params.help = false

// Show help message
if (params.help) {
    log.info """
    Data Processing Pipeline
    ========================
    
    Usage:
        nextflow run data-pipeline.nf [options]
    
    Options:
        --input <path>        Input data files (default: ${params.input})
        --output_dir <path>   Output directory (default: ${params.output_dir})
        --config <path>       Pipeline configuration file (default: ${params.config})
        --help                Show this help message
    
    Example:
        nextflow run data-pipeline.nf --input 'data/*.csv' --output_dir 'processed_data'
    """
    exit 0
}

// Log pipeline parameters
log.info """
Data Processing Pipeline
========================
Input files: ${params.input}
Output directory: ${params.output_dir}
Configuration: ${params.config}
"""

// Input channels
input_files = Channel.fromPath(params.input)

/*
 * Process 1: Validate input data
 */
process validate_data {
    tag "Validating ${file.name}"
    
    input:
    path file from input_files
    
    output:
    path file into validated_files
    path "${file.baseName}_validation_report.json" into validation_reports
    
    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import json
    from pathlib import Path
    
    # Load data
    df = pd.read_csv('${file}')
    
    # Basic validation
    validation_results = {
        'file': '${file.name}',
        'shape': df.shape,
        'columns': df.columns.tolist(),
        'missing_values': df.isnull().sum().to_dict(),
        'duplicates': df.duplicated().sum(),
        'data_types': df.dtypes.astype(str).to_dict()
    }
    
    # Save validation report
    with open('${file.baseName}_validation_report.json', 'w') as f:
        json.dump(validation_results, f, indent=2)
    
    print(f"Validation completed for {df.shape[0]} rows, {df.shape[1]} columns")
    """
}

/*
 * Process 2: Clean data
 */
process clean_data {
    tag "Cleaning ${file.name}"
    
    input:
    path file from validated_files
    
    output:
    path "${file.baseName}_cleaned.csv" into cleaned_files
    path "${file.baseName}_cleaning_report.json" into cleaning_reports
    
    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import json
    
    # Load data
    df = pd.read_csv('${file}')
    original_shape = df.shape
    
    # Data cleaning steps
    # 1. Remove duplicates
    df_clean = df.drop_duplicates()
    
    # 2. Handle missing values (drop rows with any missing values)
    df_clean = df_clean.dropna()
    
    # 3. Reset index
    df_clean = df_clean.reset_index(drop=True)
    
    final_shape = df_clean.shape
    
    # Save cleaned data
    df_clean.to_csv('${file.baseName}_cleaned.csv', index=False)
    
    # Generate cleaning report
    cleaning_report = {
        'file': '${file.name}',
        'original_shape': original_shape,
        'final_shape': final_shape,
        'rows_removed': original_shape[0] - final_shape[0],
        'cleaning_steps': [
            'remove_duplicates',
            'drop_missing_values',
            'reset_index'
        ]
    }
    
    with open('${file.baseName}_cleaning_report.json', 'w') as f:
        json.dump(cleaning_report, f, indent=2)
    
    print(f"Cleaning completed: {original_shape} -> {final_shape}")
    """
}

/*
 * Process 3: Feature engineering
 */
process feature_engineering {
    tag "Feature engineering ${file.name}"
    
    input:
    path file from cleaned_files
    
    output:
    path "${file.baseName}_features.csv" into feature_files
    path "${file.baseName}_features_report.json" into feature_reports
    
    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import numpy as np
    import json
    
    # Load cleaned data
    df = pd.read_csv('${file}')
    original_columns = df.columns.tolist()
    
    # Feature engineering examples
    # Note: These are generic examples - customize based on your data
    
    # 1. Create interaction features for numeric columns
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) >= 2:
        for i, col1 in enumerate(numeric_cols):
            for col2 in numeric_cols[i+1:]:
                df[f'{col1}_x_{col2}'] = df[col1] * df[col2]
    
    # 2. Create polynomial features for numeric columns
    for col in numeric_cols:
        if df[col].std() > 0:  # Avoid constant columns
            df[f'{col}_squared'] = df[col] ** 2
    
    # 3. Create statistical features
    if len(numeric_cols) > 0:
        df['numeric_mean'] = df[numeric_cols].mean(axis=1)
        df['numeric_std'] = df[numeric_cols].std(axis=1)
    
    final_columns = df.columns.tolist()
    new_features = [col for col in final_columns if col not in original_columns]
    
    # Save feature-engineered data
    df.to_csv('${file.baseName}_features.csv', index=False)
    
    # Generate feature engineering report
    feature_report = {
        'file': '${file.name}',
        'original_features': len(original_columns),
        'final_features': len(final_columns),
        'new_features': new_features,
        'feature_types': {
            'interaction': [f for f in new_features if '_x_' in f],
            'polynomial': [f for f in new_features if '_squared' in f],
            'statistical': [f for f in new_features if f in ['numeric_mean', 'numeric_std']]
        }
    }
    
    with open('${file.baseName}_features_report.json', 'w') as f:
        json.dump(feature_report, f, indent=2)
    
    print(f"Feature engineering completed: {len(original_columns)} -> {len(final_columns)} features")
    """
}

/*
 * Process 4: Data quality assessment
 */
process quality_assessment {
    tag "Quality assessment ${file.name}"
    publishDir params.output_dir, mode: 'copy'
    
    input:
    path file from feature_files
    
    output:
    path "${file.baseName}_final.csv" into final_files
    path "${file.baseName}_quality_report.json" into quality_reports
    
    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import numpy as np
    import json
    from scipy import stats
    
    # Load feature-engineered data
    df = pd.read_csv('${file}')
    
    # Quality assessment
    quality_metrics = {
        'file': '${file.name}',
        'final_shape': df.shape,
        'data_quality': {
            'missing_values': df.isnull().sum().sum(),
            'duplicate_rows': df.duplicated().sum(),
            'constant_columns': (df.nunique() == 1).sum(),
            'high_cardinality_columns': (df.nunique() > df.shape[0] * 0.9).sum()
        },
        'numeric_summary': {},
        'categorical_summary': {}
    }
    
    # Numeric column analysis
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        quality_metrics['numeric_summary'] = {
            'count': len(numeric_cols),
            'columns': numeric_cols.tolist(),
            'distributions': {}
        }
        
        for col in numeric_cols:
            if df[col].std() > 0:
                skewness = stats.skew(df[col].dropna())
                kurtosis = stats.kurtosis(df[col].dropna())
                quality_metrics['numeric_summary']['distributions'][col] = {
                    'skewness': float(skewness),
                    'kurtosis': float(kurtosis),
                    'outliers_iqr': int(((df[col] < (df[col].quantile(0.25) - 1.5 * (df[col].quantile(0.75) - df[col].quantile(0.25)))) | 
                                        (df[col] > (df[col].quantile(0.75) + 1.5 * (df[col].quantile(0.75) - df[col].quantile(0.25))))).sum())
                }
    
    # Categorical column analysis
    categorical_cols = df.select_dtypes(include=['object']).columns
    if len(categorical_cols) > 0:
        quality_metrics['categorical_summary'] = {
            'count': len(categorical_cols),
            'columns': categorical_cols.tolist(),
            'cardinality': {col: df[col].nunique() for col in categorical_cols}
        }
    
    # Save final processed data
    df.to_csv('${file.baseName}_final.csv', index=False)
    
    # Save quality report
    with open('${file.baseName}_quality_report.json', 'w') as f:
        json.dump(quality_metrics, f, indent=2, default=str)
    
    print(f"Quality assessment completed for {df.shape[0]} rows, {df.shape[1]} features")
    """
}

/*
 * Process 5: Generate summary report
 */
process generate_summary {
    tag "Generating summary report"
    publishDir params.output_dir, mode: 'copy'
    
    input:
    path validation_reports from validation_reports.collect()
    path cleaning_reports from cleaning_reports.collect()
    path feature_reports from feature_reports.collect()
    path quality_reports from quality_reports.collect()
    
    output:
    path "pipeline_summary_report.json"
    
    script:
    """
    #!/usr/bin/env python3
    import json
    import glob
    from datetime import datetime
    
    # Collect all reports
    validation_files = glob.glob('*_validation_report.json')
    cleaning_files = glob.glob('*_cleaning_report.json')
    feature_files = glob.glob('*_features_report.json')
    quality_files = glob.glob('*_quality_report.json')
    
    # Load and aggregate reports
    summary = {
        'pipeline_execution': {
            'timestamp': datetime.now().isoformat(),
            'files_processed': len(validation_files)
        },
        'validation_summary': [],
        'cleaning_summary': [],
        'feature_summary': [],
        'quality_summary': []
    }
    
    # Aggregate validation reports
    for file in validation_files:
        with open(file, 'r') as f:
            summary['validation_summary'].append(json.load(f))
    
    # Aggregate cleaning reports
    for file in cleaning_files:
        with open(file, 'r') as f:
            summary['cleaning_summary'].append(json.load(f))
    
    # Aggregate feature reports
    for file in feature_files:
        with open(file, 'r') as f:
            summary['feature_summary'].append(json.load(f))
    
    # Aggregate quality reports
    for file in quality_files:
        with open(file, 'r') as f:
            summary['quality_summary'].append(json.load(f))
    
    # Save summary report
    with open('pipeline_summary_report.json', 'w') as f:
        json.dump(summary, f, indent=2, default=str)
    
    print("Pipeline summary report generated successfully")
    """
}

/*
 * Workflow completion
 */
workflow.onComplete {
    log.info """
    Pipeline execution completed!
    =================================
    Success: ${workflow.success}
    Duration: ${workflow.duration}
    Output directory: ${params.output_dir}
    """
}
