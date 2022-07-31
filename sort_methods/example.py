import xxx
import yyy as y
from zzz import z, zz
import urllib.request

import re
from decimal import Decimal

def test_func():
    pass

class A(z):
    """sadfasd
    sdafasdf
    sdffa
    """
    _class_attr = "abc"

    @property
    def test_pro(self):
        '''A test property'''
        return "pro"

    @classmethod
    def test_class(cls):
        """A class method"""
        return cls()

    @staticmethod
    def test_static():
        """A static method
        """
        return 123

    # bbb comment
    _bbb = "bbb"

    # aaa comment 1
    # aaa comment 2
    _aaa = "aaa"

    def __new__(cls: type[Self]) -> Self:
        return super().__new__()

    def _abc(self):
        """asdf
        sdf
        """
        return "A protected method"

    def __init__(self, name, age):
        """_summary_
        """
        # 名字
        self.name = name
        # 年龄
        self.age = age
        print("Init method")

    # ccc comment
    _ccc = 'ccc'

    def func(self):
        """sdfffsd"""
        print("A common method")

print("In example.py")

def test_func2():
    pass


print("OK.")
