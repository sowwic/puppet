import puppet


def test_package_imports():
    assert puppet.__name__ == "puppet"
