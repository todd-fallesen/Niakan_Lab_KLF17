%Dec 1, 2020, All Purpose Data Wrangling
%Sept 9, 2020, Original scripting
%Commented for publication Septemeber 2021
%Todd Fallesen, CALM Facility, Francis Crick Institute

%{
The basis of this script is to scan over the output csv files from the
CellProfiler pipeline and group all the useful data for each nucleus by
grouping by the TrackObjects_Label_2 identifier. As a nucleus is tracked
through the Z-stack, the TrackObjects_Label_2 identifier will be unique for
each nucleus through the stack, even though the individual nucleii per
slice will have different object numbers.  Example: If there is a nucleus
in frame 10, 11, 12, 13, 14 it might have object number 1, 3, 2, 5, 7
depending in those slices. Since the nucleus is then tracked, object 1 of
frame 10 gets TrackObjects_Label_2 identifier==2, and that same identifier
would be given to frame 11, object 3, frame 12, object 2, etc. So, you'd
get
Frame  object TrackObjects_Label_2
10      1           2
11      3           2
12      2           2
13      5           2
14      7           2

If you're familiar with the 'groupby' function in python pandas, this is
the same. 

If all the output directories are subdirectories of the input_path, then
this script will scan all subdirectories of the input_path, look for the
file set by "filename" and do this calculation, independently, for each
output dataset. 

The script will save an excel workbook with the output folder name as the
start of the filename.  The script will also attempt to build a 'master' excel
file with each worksheet being a different dataset, but this will fail if
the output path names are too long, as it's an excel limitation.

If you want to change the variables that are grouped and integrated over
the nucleus, it needs to be changed three places:

1.) In the variable Small_Table, which reads in the data from the CellProfiler
output csv file

2.) In the loop for  for k = 1:length(All_tracked_objects) where we loop
over Small_table to create table_for_tracked_object and either sum or look for the max of the variables

3.) In the column_headers variable. Note, the column headers need to be the
same length as table_for_tracked_object and in the same order (as they are
the ...column headers... for table_for_tracked_object when it is written
out.

%}

%{ 
PARAMETER SETTING
input_path is just the directory where all the subdirectories are

filename is the filename that will be scanned in each subdirectory

save_file_name is the name of the output file you want to look at in
Excel
%}


clear all

tic

%%CHANGE THESE
%Path to directory
input_path = '/camp/stp/lm/outputs/niakank/Todd_for_Rebecca/August_12_2021_beta/'; %the directory where all the output subdirectories are
filename = 'July_21_2021_Pipeline_CP4_750_output_Objects_edge_size_filtered.csv';  %the file we will be looking for in each subdirectory
save_file_name  = 'August_12_2021_Rebecca_Lea_Output.xlsx';
%%%%



all_data_output_file = strcat(input_path, save_file_name);
save_path = input_path;

all_files = dir(input_path);                                        %get a list of all the files and subdirectories in the main folder
subFolders = all_files([all_files.isdir]);                          %get a list of all the subdirectories only
subFolders(ismember( {subFolders.name}, {'.', '..'})) = [];         %remove . and .. directories.

%%loop over 

%%need to insert a try-catch for the times when a file isn't actually read.
%%
for n=1:length(subFolders) %loop over the subdirectories
    disp("run number")
    n
    
    id = subFolders(n).name;            %gets the subfolder name
    
      if length(id) > 31
         id_short = id(1:31);
      else
          id_short = id;
      end
    
 
    csv_input_file = strcat(input_path, id, filesep,filename);
    excel_out_file = strcat(id,'.xlsx');%makes the excel file name per embyro
    SaveFileName = strcat(save_path, excel_out_file);
    
    clear Filename_table Small_Table Tracked_objects All_tracked_objects table_for_tracked_object output_table
    try
    	Filename_table = readtable(csv_input_file, 'Delimiter', ','); %read in the data for the filenames
    catch
        pause(1);
        Filename_table = readtable(csv_input_file, 'Delimiter', ',');
    end
    
    if height(Filename_table)==0 %%try again if the file doesn't read
        pause(1);
        disp("Stuck on File");
        disp(csv_input_file);
        Filename_table = readtable(csv_input_file, 'Delimiter', ','); %read in the data for the filenames
    
    else
    
%%        
    %small table reads the big table for the necessary variables for data analysis.  If we need more variables, add them here, and rebuild the array underneath to export)    
    

    Small_Table = Filename_table(:,{'ImageNumber',...
                                    'ObjectNumber',...
                                    'Intensity_IntegratedIntensity_DAPI',...
                                    'Intensity_IntegratedIntensity_c1',...
                                    'Intensity_IntegratedIntensity_c1_Corr',...
                                    'Intensity_IntegratedIntensity_c1_Enhanced',...
                                    'Intensity_IntegratedIntensity_c1_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c2',...
                                    'Intensity_IntegratedIntensity_c2_Corr',...
                                    'Intensity_IntegratedIntensity_c2_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c2_enhanced',...
                                    'Intensity_IntegratedIntensity_c3',...
                                    'Intensity_IntegratedIntensity_c4',...
                                    'Intensity_IntegratedIntensity_c4_Corr',...
                                    'Intensity_IntegratedIntensity_c4_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c4_enhanced',...                              
                                    'AreaShape_Eccentricity',...
                                    'AreaShape_Area', ...
                                    'TrackObjects_Label_2',...
                                    'TrackObjects_Lifetime_2'}); %make a new table with just the columns that we need
    
    
    Tracked_objects = Small_Table(:,{'TrackObjects_Label_2'});
    All_tracked_objects = table2array(unique(Tracked_objects));  %make a table that has all the unique tracked objects, then make an array from that table
    All_tracked_objects = All_tracked_objects(~isnan(All_tracked_objects));  %remove NaN's
    %there should be tracked objects in order, that shouldn't change, but in
    %the off chance that they do, set up the loop for the length of the array,
    %then call each value of the array, as opposed to just a value

    total_intensity = [];
%%
%Build the array of the new short table for data-analysis, if variables are
% %added above, be sure to add them here as well.

                         
    for k = 1:length(All_tracked_objects)
        table_for_tracked_object = Small_Table(Small_Table.TrackObjects_Label_2 == All_tracked_objects(k),:);
                                    total_intensity(k,1) = All_tracked_objects(k);
                                    total_intensity(k,2) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_DAPI);
                                    total_intensity(k,3) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c1);
                                    total_intensity(k,4) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c1_Corr);
                                    total_intensity(k,5) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c1_Enhanced);
                                    total_intensity(k,6) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c1_Enhanced_Corr);
                                    total_intensity(k,7) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c2);
                                    total_intensity(k,8) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c2_Corr);
                                    total_intensity(k,9) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c2_Enhanced_Corr);
                                    total_intensity(k,10) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c2_enhanced);
                                    total_intensity(k,11) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c3);
                                    total_intensity(k,12) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c4);
                                    total_intensity(k,13) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c4_Corr);
                                    total_intensity(k,14) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c4_Enhanced_Corr);
                                    total_intensity(k,15) = sum(table_for_tracked_object.Intensity_IntegratedIntensity_c4_enhanced);
                                    total_intensity(k,16) = max(table_for_tracked_object.AreaShape_Eccentricity);
                                    total_intensity(k,17) = sum(table_for_tracked_object.AreaShape_Area);
                                    total_intensity(k,18) = max(table_for_tracked_object.TrackObjects_Lifetime_2'); %make a new table with just the columns that we need
    end

    %column headers for the new excel spreadsheet
    column_headers = {'Tracked_Object_Number',...
                                    'Intensity_IntegratedIntensity_DAPI',...
                                    'Intensity_IntegratedIntensity_c1',...
                                    'Intensity_IntegratedIntensity_c1_Corr',...
                                    'Intensity_IntegratedIntensity_c1_Enhanced',...
                                    'Intensity_IntegratedIntensity_c1_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c2',...
                                    'Intensity_IntegratedIntensity_c2_Corr',...
                                    'Intensity_IntegratedIntensity_c2_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c2_enhanced',...
                                    'Intensity_IntegratedIntensity_c3',...
                                    'Intensity_IntegratedIntensity_c4',...
                                    'Intensity_IntegratedIntensity_c4_Corr',...
                                    'Intensity_IntegratedIntensity_c4_Enhanced_Corr',...
                                    'Intensity_IntegratedIntensity_c4_enhanced',...
                                    'Max_Eccentricity',...
                                    'Total_Area',...
                                    'Lifetime'};  %generate headers for the columns for the output spreadsheet


    %build the excel spreadsheet
    output_table = array2table(total_intensity, 'VariableNames', column_headers);
    pause(2); %race condition for saving to the tables
    writetable(output_table, SaveFileName); %save the excel file
    pause(5); %try to beat the race conditions
    writetable(output_table, all_data_output_file, 'Sheet', id_short);
    end
end
elapsed_time = toc
disp(elapsed_time)