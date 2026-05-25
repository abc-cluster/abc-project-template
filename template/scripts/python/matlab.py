import matlab.engine

# Start MATLAB engine
eng = matlab.engine.start_matlab()

# Example: Load a sequence alignment file (e.g., FASTA format)
alignment = eng.basecount('TAGCTGGCCAAGCGAGCTTG')

# Display the alignment
print(alignment)

# Stop the MATLAB engine
eng.quit()
