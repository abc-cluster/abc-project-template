#!/usr/bin/env python3
"""
Comprehensive Data Validation Suite
Integrates Great Expectations, Pandera, and custom validation logic
"""

from typing import Dict, List, Any, Optional
import pandas as pd
import numpy as np
from pathlib import Path
import great_expectations as gx
from great_expectations.checkpoint import Checkpoint
import pandera as pa
from pandera import Column, DataFrameSchema, Check
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataValidationSuite:
    """Comprehensive data validation using multiple frameworks."""
    
    def __init__(self, project_root: Path):
        self.project_root = Path(project_root)
        self.validation_results = {}
        self.setup_great_expectations()
        
    def setup_great_expectations(self):
        """Initialize Great Expectations context."""
        try:
            self.context = gx.get_context(
                context_root_dir=str(self.project_root / "analysis" / "data" / "gx")
            )
        except Exception:
            # Create new context if doesn't exist
            self.context = gx.get_context(
                context_root_dir=str(self.project_root / "analysis" / "data" / "gx"),
                mode="directory"
            )
    
    def create_data_schema(self, df: pd.DataFrame, schema_name: str) -> DataFrameSchema:
        """
        Auto-generate Pandera schema from DataFrame.
        
        Args:
            df: DataFrame to analyze
            schema_name: Name for the schema
            
        Returns:
            Pandera DataFrameSchema
        """
        columns = {}
        
        for col in df.columns:
            dtype = df[col].dtype
            
            # Basic type checking
            checks = []
            
            if pd.api.types.is_numeric_dtype(dtype):
                # Numeric column validations
                min_val = df[col].min()
                max_val = df[col].max()
                checks.extend([
                    Check.greater_than_or_equal_to(min_val),
                    Check.less_than_or_equal_to(max_val)
                ])
                
                # Check for reasonable ranges
                if col.lower() in ['age', 'years']:
                    checks.append(Check.between(0, 150))
                elif col.lower() in ['price', 'cost', 'amount']:
                    checks.append(Check.greater_than_or_equal_to(0))
                    
            elif pd.api.types.is_string_dtype(dtype):
                # String column validations
                max_length = df[col].str.len().max()
                checks.extend([
                    Check.str_length(min_value=1, max_value=max_length),
                ])
                
                # Email validation
                if 'email' in col.lower():
                    checks.append(Check.str_matches(r'^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$'))
                    
            elif pd.api.types.is_datetime64_any_dtype(dtype):
                # DateTime validations
                min_date = df[col].min()
                max_date = df[col].max()
                checks.extend([
                    Check.greater_than_or_equal_to(min_date),
                    Check.less_than_or_equal_to(max_date)
                ])
            
            # Null value handling
            nullable = df[col].isnull().any()
            
            columns[col] = Column(
                dtype=dtype,
                checks=checks,
                nullable=nullable,
                description=f"Auto-generated validation for {col}"
            )
        
        schema = DataFrameSchema(
            columns=columns,
            name=schema_name,
            description=f"Auto-generated schema for {schema_name}"
        )
        
        return schema
    
    def validate_data_quality(self, df: pd.DataFrame, dataset_name: str) -> Dict[str, Any]:
        """
        Comprehensive data quality validation.
        
        Args:
            df: DataFrame to validate
            dataset_name: Name of the dataset
            
        Returns:
            Validation results dictionary
        """
        results = {
            'dataset_name': dataset_name,
            'timestamp': datetime.now().isoformat(),
            'shape': df.shape,
            'validations': {}
        }
        
        # 1. Basic structure validation
        results['validations']['structure'] = self._validate_structure(df)
        
        # 2. Missing value analysis
        results['validations']['missing_values'] = self._validate_missing_values(df)
        
        # 3. Duplicate detection
        results['validations']['duplicates'] = self._validate_duplicates(df)
        
        # 4. Data type validation
        results['validations']['data_types'] = self._validate_data_types(df)
        
        # 5. Statistical validation
        results['validations']['statistics'] = self._validate_statistics(df)
        
        # 6. Business rule validation
        results['validations']['business_rules'] = self._validate_business_rules(df)
        
        return results
    
    def _validate_structure(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate basic DataFrame structure."""
        return {
            'rows': len(df),
            'columns': len(df.columns),
            'memory_usage_mb': df.memory_usage(deep=True).sum() / 1024**2,
            'empty_dataframe': df.empty,
            'column_names': list(df.columns),
            'duplicate_columns': len(df.columns) != len(set(df.columns))
        }
    
    def _validate_missing_values(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze missing value patterns."""
        missing_stats = df.isnull().sum()
        missing_percent = (missing_stats / len(df)) * 100
        
        return {
            'total_missing': missing_stats.sum(),
            'missing_by_column': missing_stats.to_dict(),
            'missing_percentage': missing_percent.to_dict(),
            'columns_with_missing': missing_stats[missing_stats > 0].index.tolist(),
            'completely_missing_columns': missing_percent[missing_percent == 100].index.tolist()
        }
    
    def _validate_duplicates(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Detect and analyze duplicate rows."""
        duplicates = df.duplicated()
        
        return {
            'duplicate_rows': duplicates.sum(),
            'duplicate_percentage': (duplicates.sum() / len(df)) * 100,
            'unique_rows': len(df) - duplicates.sum(),
            'duplicate_indices': df[duplicates].index.tolist()
        }
    
    def _validate_data_types(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate data types and detect inconsistencies."""
        type_info = {}
        
        for col in df.columns:
            dtype = df[col].dtype
            type_info[col] = {
                'current_dtype': str(dtype),
                'inferred_dtype': pd.api.types.infer_dtype(df[col]),
                'non_null_count': df[col].count(),
                'unique_count': df[col].nunique()
            }
            
            # Type-specific validations
            if pd.api.types.is_numeric_dtype(dtype):
                type_info[col].update({
                    'has_infinity': np.isinf(df[col]).any(),
                    'has_negative': (df[col] < 0).any(),
                    'min_value': df[col].min(),
                    'max_value': df[col].max()
                })
            elif pd.api.types.is_string_dtype(dtype):
                type_info[col].update({
                    'max_length': df[col].str.len().max() if not df[col].empty else 0,
                    'min_length': df[col].str.len().min() if not df[col].empty else 0,
                    'has_special_chars': df[col].str.contains(r'[^a-zA-Z0-9\\s]').any()
                })
        
        return type_info
    
    def _validate_statistics(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Statistical validation and outlier detection."""
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        stats = {}
        
        for col in numeric_cols:
            series = df[col].dropna()
            if len(series) > 0:
                Q1 = series.quantile(0.25)
                Q3 = series.quantile(0.75)
                IQR = Q3 - Q1
                
                stats[col] = {
                    'mean': series.mean(),
                    'median': series.median(),
                    'std': series.std(),
                    'skewness': series.skew(),
                    'kurtosis': series.kurtosis(),
                    'outliers_iqr': len(series[(series < Q1 - 1.5*IQR) | (series > Q3 + 1.5*IQR)]),
                    'outliers_zscore': len(series[np.abs((series - series.mean())/series.std()) > 3])
                }
        
        return stats
    
    def _validate_business_rules(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate domain-specific business rules."""
        violations = {}
        
        # Example business rules - customize for your domain
        
        # Rule 1: Age should be reasonable if present
        if 'age' in df.columns:
            violations['invalid_age'] = len(df[(df['age'] < 0) | (df['age'] > 150)])
        
        # Rule 2: Email format validation
        email_cols = [col for col in df.columns if 'email' in col.lower()]
        for col in email_cols:
            if col in df.columns:
                email_pattern = r'^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$'
                violations[f'invalid_{col}'] = len(df[~df[col].str.match(email_pattern, na=False)])
        
        # Rule 3: Date ranges should be logical
        date_cols = df.select_dtypes(include=['datetime64']).columns
        for col in date_cols:
            future_dates = df[col] > pd.Timestamp.now()
            violations[f'future_{col}'] = future_dates.sum()
        
        return violations
    
    def create_data_profile_report(self, df: pd.DataFrame, output_path: Path) -> None:
        """Generate comprehensive data profiling report using ydata-profiling."""
        try:
            from ydata_profiling import ProfileReport
            
            profile = ProfileReport(
                df,
                title="Data Profiling Report",
                explorative=True,
                minimal=False
            )
            
            profile.to_file(output_path)
            logger.info(f"Data profile report saved to: {output_path}")
            
        except ImportError:
            logger.warning("ydata-profiling not installed. Install with: pip install ydata-profiling")
    
    def save_validation_results(self, results: Dict[str, Any], output_path: Path) -> None:
        """Save validation results to JSON file."""
        import json
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=2, default=str)
        
        logger.info(f"Validation results saved to: {output_path}")

# Example usage and testing
def example_usage():
    """Example of how to use the DataValidationSuite."""
    
    # Create sample data
    np.random.seed(42)
    sample_data = pd.DataFrame({
        'id': range(1000),
        'age': np.random.randint(18, 80, 1000),
        'salary': np.random.normal(50000, 15000, 1000),
        'email': [f'user{i}@example.com' for i in range(1000)],
        'created_at': pd.date_range('2023-01-01', periods=1000, freq='D'),
        'category': np.random.choice(['A', 'B', 'C'], 1000)
    })
    
    # Add some data quality issues for testing
    sample_data.loc[10:20, 'age'] = np.nan  # Missing values
    sample_data.loc[50, 'salary'] = -1000   # Negative salary
    sample_data.loc[100:105] = sample_data.loc[95:100].values  # Duplicates
    
    # Initialize validation suite
    validator = DataValidationSuite(Path.cwd())
    
    # Run validation
    results = validator.validate_data_quality(sample_data, "sample_dataset")
    
    # Create schema
    schema = validator.create_data_schema(sample_data, "sample_schema")
    
    # Print results
    print("Validation Results:")
    print(f"Dataset Shape: {results['shape']}")
    print(f"Missing Values: {results['validations']['missing_values']['total_missing']}")
    print(f"Duplicate Rows: {results['validations']['duplicates']['duplicate_rows']}")
    
    return results, schema

if __name__ == "__main__":
    results, schema = example_usage()
    print("\\nData validation completed successfully!")
