import os
import sys
import pytest
import numpy as np
from unittest import mock
from pytest import MonkeyPatch

@pytest.fixture
def set_sys_variables(monkeypatch):
    # Simulate command-line arguments using monkeypatch
    monkeypatch.setattr(sys, 'argv', ["script_name.py", "test_arg1", "test_arg2", "TICSC/utils/testing_data/utils","test_arg4"])
    
    # Import mTI after modifying sys.argv
    from analyzer import TI

    # Return the imported module so it can be used in tests
    return TI

def test_validate_montage_empty_montage_list(set_sys_variables):  # Pass the fixture
    TI = set_sys_variables

    montage = []  # Empty montage list
    montage_name = "test_montage"
    
    # Call validate_montage with the empty list
    result = TI.validate_montage(montage, montage_name)
    
    # Assert that the result is False
    assert result is False

def test_validate_montage_fewer_than_two_electrode_pairs(set_sys_variables):  # Pass the fixture
    TI = set_sys_variables

    # Montage with one electrode pair (fewer than 2)
    montage = [[[0, 0], [1, 1]]]
    montage_name = "test_montage"
    
    # Call validate_montage with the montage
    result = TI.validate_montage(montage, montage_name)
    
    # Assert that the result is False
    assert result is False

def test_validate_montage_valid_input(set_sys_variables):  # Pass the fixture
    TI = set_sys_variables

    # Correctly structured montage with 2 electrode pairs
    montage = [[[0, 0], [1, 1]], [[2, 2], [3, 3]]]
    montage_name = "test_montage"
    
    # Call validate_montage with the montage
    result = TI.validate_montage(montage, montage_name)
    
    # Assert that the result is True
    assert result is True