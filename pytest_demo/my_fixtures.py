import pytest
from pytest_mock import MockerFixture

import foo


def func(arg: str):
    ret = foo.my_func()
    if not isinstance(ret, str):
        return

    if arg.isupper():
        return "upper"

    if arg.islower():
        return "lower"


class MyFixture:
    @pytest.fixture
    def my_fixture(self, mocker: MockerFixture):
        mocker.patch.object(foo, "my_func", return_value="")
