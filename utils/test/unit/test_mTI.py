import os
import sys
import pytest
import numpy as np
from unittest import mock
from pytest import MonkeyPatch

@pytest.fixture
def set_sys_variables(monkeypatch):
    monkeypatch.setattr(sys, 'argv', ["script_name.py", "test_arg1", "test_arg2", "/ti-csc/utils/test/data/utils","test_arg4"])
    # Import mTI after modifying sys.argv
    print("Using Docker")
    from analyzer import mTI    
    # Return the imported module so it can be used in tests
    return mTI

def test_get_TI_vectors_zero_array(set_sys_variables):  # Pass the fixture to the test
    mTI = set_sys_variables

    E1_org = np.zeros((1,3))   # Use two zero 1x3 arrays to test the function
    E2_org = np.zeros((1,3)) 

    E1 = E1_org.astype(np.float64) # Convert the arrays to float64
    E2 = E2_org.astype(np.float64)

    TI_vectors_org = mTI.get_TI_vectors(E1, E2) # Call the function with the zero arrays
    TI_vectors = np.nan_to_num(TI_vectors_org, nan=0.0) # Convert NaNs to zeros

    # Check if the output is a 1x3 array of zeros
    assert np.all(TI_vectors == np.zeros((1,3)))

def test_get_TI_vectors_same_arrays(set_sys_variables):  # Pass the fixture to the test
    mTI = set_sys_variables

    E1_org = np.array([[1, 2, 3]])  # Use two identical 3x3 arrays to test the function
    E2_org = np.array([[1, 2, 3]])

    E1 = E1_org.astype(np.float64) # Convert the arrays to float64
    E2 = E2_org.astype(np.float64)

    TI_vectors_org = mTI.get_TI_vectors(E1, E2) # Call the function with the zero arrays
    TI_vectors = np.nan_to_num(TI_vectors_org, nan=0.0) # Convert NaNs to zeros

    print(TI_vectors)
    # Check if the output is a 3x3 array with a 2 time scale of the input arrays
    assert np.all(TI_vectors == np.array([[2,4,6],]))

def test_get_TI_vectors_different_input_sizes(set_sys_variables):  # Pass the fixture to the test
    mTI = set_sys_variables

    E1_org = np.array([[1, 2, 3]])  # Use two different sized input arrays to test the function
    E2_org = np.array([[1, 2, 3],[4, 5, 6]])

    E1 = E1_org.astype(np.float64) # Convert the arrays to float64
    E2 = E2_org.astype(np.float64)

    # Check if the function raises an AssertionError when the input arrays are of different sizes
    with pytest.raises(AssertionError):
        mTI.get_TI_vectors(E1, E2)
