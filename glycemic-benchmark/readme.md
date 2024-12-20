Setup Steps

1. Download the data from the [website](https://physionet.org/content/big-ideas-glycemic-wearable/1.1.2/)
2. Place your data in folder named "data" in this folder
3. The data folder structure will be directories with different users data and a demographics.csv file
4. Create "new_data" and "results" folder in the same level as data
5. Create a python environment and install all the libraries shared in the requirements.txt
6. Now go into code-timescale folder and make changes in config.py according to your system. 
7. Run the transform_data.py file to convert the data into ingestible format.
8. Once the new set of data is created you are good to go for the timescaledb benchmarking
9. Input the scale_factor in config.py file and also number of times you want to run the queries for statistical significance.
10. Now after modifying the config.py , open the benchmark.ipynb and run all the cells
11. Your results for the choosen scale will get populated in results folder.
