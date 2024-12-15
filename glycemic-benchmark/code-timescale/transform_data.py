import config
import os
import pandas as pd
from tqdm import tqdm
import shutil


def transform_data():

    participants = ['001','002','003','004','005','006','007','008',
     '009','010','011','012','013','014','015','016']    

    source_demographic = os.path.join(config.DATA_PATH,'Demographics.csv')
    dest_demographic = os.path.join(config.TRANSFORM_DATA_PATH,'Demographics.csv')

    shutil.copy(source_demographic, dest_demographic)
    

    for user in tqdm(participants):
        folder_path = os.path.join(config.DATA_PATH,user)
        
        for files in os.listdir(folder_path):
            
            if '.csv' in files.lower():

                file_path = os.path.join(folder_path,files)
                df = pd.read_csv(file_path)

                if 'dexcom' in files.lower():
                    df = df.loc[12:,:]
                    df = df.drop(columns=['Index'])
                    df = df.fillna("")


                df['participant_id'] = int(user)

                if not os.path.exists(os.path.join(config.TRANSFORM_DATA_PATH,f'{user}')):
                    os.mkdir(os.path.join(config.TRANSFORM_DATA_PATH,f'{user}'))

                new_file_path = os.path.join(config.TRANSFORM_DATA_PATH,f"{user}/{files}")
                

                df.to_csv(new_file_path,index=False)


    



            


if __name__ =="__main__":

    transform_data()