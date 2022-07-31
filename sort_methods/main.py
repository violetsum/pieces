#!/usr/bin/env python3

import sys
from enum import Enum
from typing import Any, Optional

import libcst as cst
from libcst import ClassDef, FunctionDef, IndentedBlock


class MethodType(Enum):
    NON_METHOD: int = 0
    NEW: int = 1
    INIT: int = 2
    POST_INIT: int = 3
    OTHER_MAGIC_METHOD: int = 4
    PROPERTY: int = 5
    STATIC_METHOD: int = 6
    CLASS_METHOD: int = 7
    COMMON_METHOD: int = 8
    PRIVATED_METHOD: int = 9


def py_code_print(code: str) -> None:
    from rich import print
    from rich.syntax import Syntax

    output = Syntax(
        code, "python3", line_numbers=True, indent_guides=True
    )
    print(output)


def is_magic_method(func_name: str) -> bool:
    return func_name.startswith("__") and func_name.endswith("__")


def is_decorated_by(decorator_name: str, func_def: FunctionDef) -> bool:
    decorators = func_def.decorators
    return any(deco.decorator.value == decorator_name for deco in decorators)


def is_decorated_by_property(func_def: FunctionDef) -> bool:
    return is_decorated_by("property", func_def)


def is_decorated_by_staticmethod(func_def: FunctionDef) -> bool:
    return is_decorated_by("staticmethod", func_def)


def is_decorated_by_classmethod(func_def: FunctionDef) -> bool:
    return is_decorated_by("classmethod", func_def)


def by_cleancode(func_def: FunctionDef | Any) -> int:
    if not isinstance(func_def, FunctionDef):
        return MethodType.NON_METHOD.value

    func_name = func_def.name.value
    match func_name, func_def:
        case "__new__", _:
            return MethodType.NEW.value
        case "__init__", _:
            return MethodType.INIT.value
        case "__pos_init__", _:
            return MethodType.POST_INIT.value
        case func_name, _ if is_magic_method(func_name):
            return MethodType.OTHER_MAGIC_METHOD.value
        case _, func_def if is_decorated_by_property(func_def):
            return MethodType.PROPERTY.value
        case _, func_def if is_decorated_by_staticmethod(func_def):
            return MethodType.STATIC_METHOD.value
        case _, func_def if is_decorated_by_classmethod(func_def):
            return MethodType.CLASS_METHOD.value
        case func_name, _ if not func_name.startswith("_"):
            return MethodType.COMMON_METHOD.value
        case _:
            return MethodType.PRIVATED_METHOD.value


class SortMethodTransformer(cst.CSTTransformer):
    def __init__(self):
        self._is_in_class = False

    def visit_ClassDef(self, node: ClassDef) -> Optional[bool]:
        self._is_in_class = True

    def leave_ClassDef(self, original_node: ClassDef,
                       updated_node: ClassDef) -> ClassDef:
        self._is_in_class = False
        return updated_node

    def leave_IndentedBlock(self, original_node: IndentedBlock,
                            updated_node: IndentedBlock) -> IndentedBlock:
        if not self._is_in_class:
            return updated_node

        body = sorted(original_node.body, key=by_cleancode)
        return updated_node.with_changes(body=body)


def main(file_path, pretty_print=False) -> None:
    with open(file_path) as f:
        content = f.read()

    src_tree = cst.parse_module(content)
    modified_tree = src_tree.visit(SortMethodTransformer())

    if pretty_print:
        py_code_print(modified_tree.code)
    else:
        print(modified_tree.code)


if __name__ == '__main__':
    argv = sys.argv
    if len(argv) < 2:
        print("Parameter error.")
        sys.exit(1)

    file_path, *rest = argv[1:]
    main(file_path, rest and rest[0])
