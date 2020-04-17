import os
import shutil

path_to_methodology = r'' #write path to files
path_to_plans = r'' #write path to files
path_to_archives = r'' #write path to files
path_tmp_files = r'' #write path to files

for _file in os.listdir(path_to_plans):
    for file in os.listdir(path_to_methodology):
        shutil.copy2(os.path.join(path_to_methodology, file), path_tmp_files)
    shutil.copy2(os.path.join(path_to_plans,_file), path_tmp_files)
    shutil.make_archive(os.path.join(path_to_archives,os.path.splitext(os.path.basename(_file))[0]), 'zip', path_tmp_files)
    for ff in os.listdir(path_tmp_files):
        os.remove(os.path.join(path_tmp_files, ff))
