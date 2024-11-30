#!/usr/bin/env bats
function setup() {
        echo "setting up..."
        script="/ti-csc/analyzer/visualize-montage.sh"
        sim_mode="U"
        output_dir="/tmp/output"
        dos2unix $script
}

@test "Example Test" {
        run echo "hello"
        [ "$status" -eq 1]
}

@test "Test Non-Exisiting Montage File" {
        export PROJECT_DIR_NAME="/tmp/mock_project_dir" # Change the project directory to a mocked project that does not contain a montage file
        # mkdir /tmp/mock_project_dir # Create a mock project folder
        # mkdir /tmp/mock_project_dir/utils # Create a mock utils folder
        run $script $sim_mode $output_dir # Run the script with good parameters
        [ "$status" -ne 0 ] # Assert the exit status is non-zero
        [[ "$output" =~ "Error: Montage file not found at: $montage_file" ]] # Assert the error message was displayed
}

@test "Test Invalid Montage Type" {
        run $script "Q" $output_dir # Call the script with a non M or U sim_mode
        [ "$status" -ne 0 ] # Assert the exit status is non-zero
        [[ "$output" =~ "Error: Invalid montage type. Please provide 'U' for Unipolar or 'M' for Multipolar." ]] # Assert the error message was displayed
}

@test "Test Non-Exisiting Output Directory" {
        run $script $sim_mode $output_dir # Call script with a Non-Exisiting Output Directory (/tmp/output) 
        [ -d $output_dir ] # Assert that the new output directory was created
}
function teardown() {
    echo "tearing down..."
}