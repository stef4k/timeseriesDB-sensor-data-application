import config
from influxdb import DataFrameClient
import pandas as pd
import os 
import timeit
import time  


def insert_acc_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    acc_df = pd.read_csv(path)
    acc_df = acc_df.rename(columns={' acc_x':'acc_x',' acc_y':'acc_y',' acc_z':'acc_z'})
    acc_df['time'] = pd.to_datetime(acc_df['datetime'])
    acc_df = acc_df.set_index('time')
    field_columns = {'acc_x': 'acc_x', 'acc_y': 'acc_y', 'acc_z': 'acc_z'}
    acc_df['participant_id'] = acc_df['participant_id'].astype(str)
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=acc_df, 
            measurement='accelerometer_data', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time
        

def insert_bvp_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    df = df.rename(columns={' bvp':'bvp'})
    df['time'] = pd.to_datetime(df['datetime'])
    df = df.set_index('time')
    field_columns={'bvp':'bvp'}
    df['participant_id'] = df['participant_id'].astype(str)
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='blood_volume_pulse', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time
    
def insert_dexcom_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    columns = [
                'ts',
                'event_type',
                'event_subtype',
                'patient_info',
                'device_info',
                'source_device_id',
                'glucose_value',
                'insulin_value',
                'carb_value',
                'duration',
                'glucose_rate_change',
                'transmitter_time',
                'participant_id'
            ]
    
    df.columns = columns
    field_columns={'event_subtype':'event_subtype',
        'patient_info':'patient_info',
        'device_info':'device_info','glucose_value':'glucose_value',
        'insulin_value': 'insulin_value',
        'carb_value': 'carb_value',
        'duration':'duration',
        'glucose_rate_change':'glucose_rate_change',
        'transmitter_time':'transmitter_time'}
    df['time'] = pd.to_datetime(df['ts'])
    df = df.set_index('time')
    df['participant_id'] = df['participant_id'].astype(str)
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='interstitial_glucose', 
            field_columns=field_columns,
            tag_columns=['participant_id','source_device_id','event_type'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time
    
def insert_eda_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    df = df.rename(columns={' eda':'eda'})
    df['participant_id'] = df['participant_id'].astype(str)
    field_columns = {'eda':'eda'}
    df['time'] = pd.to_datetime(df['datetime'])
    df = df.set_index('time')
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='electrodermal_activity', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time
    
def insert_hr_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    df = df.rename(columns={' hr':'hr'})
    field_columns = {'hr':'hr'}
    df['time'] = pd.to_datetime(df['datetime'])
    df = df.set_index('time')
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='heart_rate_data', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time

def insert_ibi_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    df = df.rename(columns={' ibi':'ibi'})
    field_columns = {'ibi':'ibi'}
    df['time'] = pd.to_datetime(df['datetime'])
    df = df.set_index('time')
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='ibi_data', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time
    

def insert_temp_data(path):
    
    total_wall_time = 0
    total_insertion_time = 0 
    df = pd.read_csv(path)
    df = df.rename(columns={' temp':'temp'})
    field_columns = {'temp':'temp'}
    df['time'] = pd.to_datetime(df['datetime'])
    df = df.set_index('time')
    wall_start_time = time.time()
    client = DataFrameClient(host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME)
    try:
        insertion_start = timeit.default_timer()
        client.write_points(
            dataframe=df, 
            measurement='temperature_data', 
            field_columns=field_columns,
            tag_columns=['participant_id'],
            batch_size=10000
        )
        insertion_end = timeit.default_timer()
        total_insertion_time = (insertion_end - insertion_start) * 1000
    except Exception as e:
        print(f"Error writing data: {e}")
    finally:
        client.close()
        wall_end_time = time.time()
        total_wall_time = (wall_end_time - wall_start_time) * 1000
        return total_wall_time, total_insertion_time