import os


def ensure_temp_path():
    temp_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), "temp")
    if not os.path.exists(temp_file):
        os.makedirs(temp_file)
