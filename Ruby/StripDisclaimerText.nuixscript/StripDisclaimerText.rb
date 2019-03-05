# Menu Title: Strip Disclaimer Text
# Needs Case: true
# Needs Selected Items: false

require_relative "Nx.jar"
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

script_directory = File.dirname(__FILE__)
load File.join(script_directory,"TextReplacer.rb")
load File.join(script_directory,"BasicQueryValidator.rb")

# Build dialog
dialog = TabbedCustomDialog.new
dialog.setTitle("Strip Disclaimer Text")
main_tab = dialog.addTab("main_tab","Main")

main_tab.appendTextField("scope_query","Scope Query (blank is all items)","")

main_tab.appendHeader(" ")
main_tab.appendOpenFileChooser("disclaimer_file","UTF8 Disclaimer Text File","Text File","txt")
main_tab.appendRadioButton("replace_with_value","Replace With Value","replacement_method",true)
main_tab.appendTextField("replacement_value","Replacement Value","DISCLAIMER REMOVED")
main_tab.enabledOnlyWhenChecked("replacement_value","replace_with_value")
main_tab.appendRadioButton("replace_with_file","Replace With File","replacement_method",false)
main_tab.appendOpenFileChooser("replacement_file","Replacement Text File","Text File","txt")
main_tab.enabledOnlyWhenChecked("replacement_file","replace_with_file")

main_tab.appendHeader(" ")
main_tab.appendCheckBox("tag_modified","Tag Modified Items",false)
main_tab.appendTextField("modified_tag","Modified Item Tag","DisclaimerStrippedFromText")
main_tab.enabledOnlyWhenChecked("modified_tag","tag_modified")

# Define user input validations
dialog.validateBeforeClosing do |values|
	if !java.io.File.new(values["disclaimer_file"]).exists
		CommonDialogs.showError("Invalid disclaimer file path provided.")
		next false
	end

	if values["replace_with_file"] && !java.io.File.new(values["replacement_file"]).exists
		CommonDialogs.showError("Invalid replacement file path provided.")
		next false
	end

	query_validation = BasicQueryValidator.check(values["scope_query"])
	if query_validation != true
		CommonDialogs.showError("Please check your scope query:\n\n#{query_validation}")
		next false
	end

	if values["tag_modified"] && (values["modified_tag"].nil? || values["modified_tag"].strip.empty?)
		CommonDialogs.showError("Please provide a valid Tag")
		next false
	end

	# Get user confirmation about closing all workbench tabs
	if CommonDialogs.getConfirmation("The script needs to close all workbench tabs, proceed?") == false
		next false
	end

	next true
end

# Display dialog
dialog.display

# Get to work if the user hit the okay button
if dialog.getDialogResult == true
	$window.closeAllTabs
	# Get dialog values
	values = dialog.toMap
	# Load disclaimer text from file
	disclaimer_text = File.read(values["disclaimer_file"])
	# Create TextReplacer instance
	replacer = TextReplacer.new(disclaimer_text)
	# Get criteria which is safe for searching
	disclaimer_criteria = replacer.get_query_criteria
	# Work out what the replacement text will be
	replacement_text = nil
	if values["replacement_value"]
		replacement_text = values["replacement_value"]
	else
		replacement_text = File.read(values["replacement_file"])
	end
	# This will track how many items had their text modified
	replaced_count = 0
	# Show the progress dialog
	ProgressDialog.forBlock do |pd|
		# Hide the sub progress bar, we wont need it
		pd.setSubProgressVisible(false)

		# Log what settings are going to be user and obtain the items
		# we will check
		pd.logMessage("Disclaimer Text:\n\n#{disclaimer_text}")
		pd.logMessage("\nReplacement Text:\n\n#{replacement_text}")
		pd.logMessage("\nScope Query: #{values["scope_query"]}")
		if values["tag_modified"]
			pd.logMessage("Tag: #{values["modified_tag"]}")
		end
		# Build our actual query
		query_pieces = []
		query_pieces << values["scope_query"]
		query_pieces << disclaimer_criteria
		final_query = query_pieces.reject{|p|p.strip.empty?}.map{|p|"(#{p})"}.join(" AND ")
		pd.logMessage("Actual Query: #{final_query}")

		#Search for hits
		items = $current_case.searchUnsorted(final_query)
		pd.logMessage("Hits: #{items.size}")
		pd.setMainStatusAndLogIt("Processing...")
		pd.setMainProgress(0,items.size)

		# Enter write access block
		$current_case.withWriteAccess do 
			# Iterate the hits
			items.each_with_index do |item,item_index|
				# Abort if user requested us to
				break if pd.abortWasRequested
				# Update main progress bar
				pd.setMainProgress(item_index+1)
				pd.logMessage("Processing #{item.getName}")
				# Check if item text appears to have a match
				if replacer.has_match(item)
					pd.logMessage("\tHas match")
					# Modify item text since it does
					replacer.perform_replacement(item,replacement_text)
					# Tag item if user asked us to
					if values["tag_modified"]
						item.addTag(values["modified_tag"])
					end
					# Count as replacement
					replaced_count += 1
				else
					pd.logMessage("\tNo match")
				end
			end
		end

		# Show final replacement count
		pd.logMessage("Text Replaced: #{replaced_count}")
		# Show message that we either completed or that the user hit abort
		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("User Aborted")
		else
			pd.setMainStatusAndLogIt("Completed")
		end
		$window.openTab("workbench",{:search => ""})
	end
end