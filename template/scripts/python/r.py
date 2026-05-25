import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
from rpy2.robjects.lib import grdevices

# Run a simple R command
robjects.r('x <- rnorm(10)')
robjects.r('print(x)')

# Get R variable into Python
x = robjects.r('x')
print(list(x))

# Import ggplot2
ggplot2 = importr('ggplot2')

# Create a simple data frame in R
robjects.r('''
    df <- data.frame(
        x = 1:10,
        y = (1:10) + rnorm(10)
    )
''')

# Create a plot and save it as a PNG
with grdevices.render_to_bytesio(grdevices.png, width=512, height=512, res=100) as img:
    robjects.r('''
        p <- ggplot(df, aes(x=x, y=y)) + geom_point() + ggtitle("Example ggplot2 Scatterplot")
        print(p)
    ''')
    plot_bytes = img.getvalue()

# Save the image to a file (optional)
with open("ggplot_example.png", "wb") as f:
    f.write(plot_bytes)
