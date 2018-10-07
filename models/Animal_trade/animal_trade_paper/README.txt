Exponential Random Graph Models for Shiny dashboard 

- Used btergm package to model networks as snapshots over months
- si_be.csv is data acquired from model_get_data.R function in "src\data\src\shiny_dashboard\model_get_data.R"  
- See folder "btergm_package_info_useful_papers" for more info and useful papers 
- Model outputs were saved as .rds files for dashboard
- For dashboard to work, also need to save a model.rds and net_list.rds for each commodity. 
- If you would like to add another commodity to the dash:
	1. Change net_list name at line 42
	2. Update line 79 to update new net_list name
	3. Update call to net_list for model at line 90
	4. Change model file name at line 102
	5. Change net_list name at line 105 