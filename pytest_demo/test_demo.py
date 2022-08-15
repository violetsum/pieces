import pytest

from my_fixtures import MyFixture, func


class TestClass(MyFixture):
    @pytest.mark.parametrize("arg, expected_result",
                            [("abc", "lower"),
                            ("ABC", "upper")])
    def test_my_func(self, arg, expected_result, my_fixture):
        assert func(arg) == expected_result

