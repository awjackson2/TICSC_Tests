#!/usr/bin/env bats

# Setup function to initialize variables and check permissions
function setup() {
    echo "setting up..."
    script="/ti-csc/analyzer/visualize-montage.sh"
    sim_mode="U"
    output_dir="/tmp/output"
    
    # Ensure script exists
    if [ ! -f "$script" ]; then
        echo "Error: Script $script does not exist."
        exit 1
    fi

    # Debug permissions and ownership
    echo "Script permissions before setup:"
    ls -l "$script"
    echo "Current user: $(whoami)"

    # Convert line endings and ensure execution permission
    dos2unix "$script"
    chmod +x "$script" # Add executable permission
    ls -l "$script" # Debug to confirm permissions are updated
}

@test "Example Test" {
    run echo hello
    [ "$output" == hello ]
}

@test "Test Non-Exisiting Montage File" {
    export PROJECT_DIR_NAME="/tmp/mock_project_dir" # Mock project directory
    mkdir -p "$PROJECT_DIR_NAME" # Ensure the directory exists

    # Debug environment
    echo "Testing with project directory: $PROJECT_DIR_NAME"
    echo "Testing with script: $script"
    echo "Script permissions:"
    ls -l "$script"

    # Run test
    run $script $sim_mode $output_dir
    [ "$status" -ne 0 ] # Assert the exit status is non-zero

    # Debugging output comparison
    if [[ "$output" != *"Error: Montage file not found at: $montage_file"* ]]; then
        echo "Expected error message: 'Error: Montage file not found at: $montage_file'"
        echo "Actual output: $output"
    fi

    [[ "$output" =~ "Error: Montage file not found at: $montage_file" ]] # Assert the error message was displayed
}

@test "Test Invalid Montage Type" {
    echo "Running invalid montage type test..."

    # Debug permissions and setup
    echo "Script permissions:"
    ls -l "$script"

    # Run test
    run $script "Q" $output_dir
    [ "$status" -ne 0 ] # Assert the exit status is non-zero

    # Debugging output comparison
    if [[ "$output" != *"Error: Invalid montage type. Please provide 'U' for Unipolar or 'M' for Multipolar."* ]]; then
        echo "Expected error message: 'Error: Invalid montage type. Please provide 'U' for Unipolar or 'M' for Multipolar.'"
        echo "Actual output: $output"
    fi

    [[ "$output" =~ "Error: Invalid montage type. Please provide 'U' for Unipolar or 'M' for Multipolar." ]] # Assert the error message was displayed
}

@test "Test Non-Exisiting Output Directory" {
    echo "Testing with output directory: $output_dir"

    # Debug and ensure permissions
    echo "Output directory permissions before test:"
    ls -ld "$(dirname "$output_dir")"

    # Run test
    run $script $sim_mode $output_dir

    # Debugging output comparison
    if [ ! -d "$output_dir" ]; then
        echo "Expected: Directory $output_dir to be created."
        echo "Actual: Directory $output_dir does not exist."
    fi

    [ -d $output_dir ] # Assert that the new output directory was created
}

# Teardown function to clean up
function teardown() {
    echo "tearing down..."
    # Optionally remove temporary files or directories
    if [ -d "$output_dir" ]; then
        rm -rf "$output_dir"
    fi
}
