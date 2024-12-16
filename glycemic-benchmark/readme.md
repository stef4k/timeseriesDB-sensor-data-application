Setup Steps

1. Place your data folder named "data" in this repository 
2. The data folder structure will be directories with different users data and a demographics.csv file
3. Create "new_data" and "results" folder in the same level as data
4. Create a python environment and install all the libraries shared in the requirements.txt
5. Now go into code-timescale folder and make changes in config.py according to your system. 
6. Run the transform_data.py file to convert the data into ingestible format.
7. Once the new set of data is created you are good to go for the timescaledb benchmarking
8. Input the scale_factor in config.py file and also number of times you want to run the queries for statistical significance.
9. Now after modifying the config.py , open the benchmark.ipynb and run all the cells
10. Your results for the choosen scale will get populated in results folder.
