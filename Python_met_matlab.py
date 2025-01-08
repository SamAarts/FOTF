import matlab.engine
import streamlit as st
import pandas as pd
import plotly.express as px
import numpy as np
import tempfile
from pathlib import Path
from PIL import Image


# eng = matlab.engine.start_matlab()

# getallen_double = matlab.double([2,6,5,9])
# gem = eng.Gemiddelde(getallen_double)

# print(gem)

# eng.quit()


############################
st.set_page_config(
    page_title='Leerdoel 3',        
    layout="wide",                         
    page_icon="🤖",                         
    initial_sidebar_state="expanded",       
)



def verberg_suffe_icoontjes():
            st.markdown("""
    <style>
    /* Hide the link button */
    .stApp a:first-child {
        display: none;
    }
    
    .css-15zrgzn {display: none}
    .css-eczf16 {display: none}
    .css-jn99sy {display: none}
    </style>
    """, unsafe_allow_html=True)
            
            
if 'page' not in st.session_state:
    st.session_state['page'] = 'Upload and validate'   
    st.session_state['df_omloop'] = None               
    st.session_state['df_timetable'] = None            
    st.session_state['format_check'] = None            
    st.session_state['onderbouwingen'] = None           
    st.session_state['bestand'] = None          
    st.session_state['bussen'] = None   





def upload_validate_page():

    image_formats = ["bmp", "cur", "gif", "ico", "jpg", "jpeg", "jp2", "pbm", "pgm", "ppm", "png", "pnm", "ras", "tif", "tiff", "xwd"]
    video_formats = ["avi", "mpg", "mpeg", "mp4", "mov", "m4v", "wmv", "asf"]
    formats = ["bmp", "cur", "gif", "ico", "jpg", "jpeg", "jp2", "pbm", "pgm", "ppm", "png", "pnm", "ras", "tif", "tiff", "xwd","avi", "mpg", "mpeg", "mp4", "mov", "m4v", "wmv", "asf"]

    verberg_suffe_icoontjes()                
    st.title('Importeer bestanden')         
    bestand = st.file_uploader('Upload foto of video', type=formats)
    st.session_state['bestand'] = bestand  

    col1, col2, col3 = st.columns([1,2,1])


    if bestand is not None:
        bestand_naam = bestand.name.lower() 
        extensie = bestand_naam.split(".")[-1]  

        if extensie in image_formats:

            with tempfile.NamedTemporaryFile(delete=False, suffix=f".{extensie}") as input_file:
                input_file.write(bestand.read())
                input_file_path = input_file.name

            output_file_path = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg").name

            eng = matlab.engine.start_matlab()
            eng.GezichtsherkenningFoto(input_file_path, output_file_path, nargout=0)
            eng.quit()

            output_image = Image.open(output_file_path)
            col2.image(output_image, caption="Gezichtsherkenning voltooid", use_column_width=True)


        elif extensie in video_formats:
            with tempfile.NamedTemporaryFile(delete=False, suffix=f".{extensie}") as input_file:
                input_file.write(bestand.read())
                input_file_path = input_file.name
            
            output_file_path = tempfile.NamedTemporaryFile(delete=False, suffix=".mp4").name

            eng = matlab.engine.start_matlab()
            eng.GezichtsherkenningVideo(input_file_path, output_file_path, nargout=0)
            eng.quit()

            # Display the processed video (if possible)
            col2.video(output_file_path)
        
        
        else:
             st.write("Het bestandstype word niet ondersteund")





if st.session_state['page'] == 'Upload and validate' or st.session_state['page'] == 'Import New Excel':
    upload_validate_page()
else:
    
    st.sidebar.title("Navigation")
    selected_page = st.sidebar.selectbox(
        "Select a page",
        ('Overview', "Bus Specific Schedule", "Gantt Chart",'Import New Excel'),
        index=0
    )

    # if selected_page == 'Overview':
    #     Overview()
    # elif selected_page == 'Import New Excel':
    #     upload_validate_page()
    #     st.session_state['page'] = selected_page
    #     st.rerun()
    # elif selected_page == "Bus Specific Schedule":
    #     Bus_Specific_Schedule()
    # elif selected_page == 'Gantt Chart':
    #     Gantt_Chartbestand()