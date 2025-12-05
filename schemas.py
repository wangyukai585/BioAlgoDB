"""Marshmallow 序列化 Schema 定义：解决循环引用、控制字段输出（中文注释版）。"""

from flask_marshmallow import Marshmallow
from marshmallow import EXCLUDE, fields

from models import Algorithm, Lab, Paper, Problem, Tool, User, db

# 全局单例，供应用初始化
ma = Marshmallow()


class ProblemSchema(ma.SQLAlchemyAutoSchema):
    """问题实体的序列化，嵌套算法列表，避免递归回溯。"""

    class Meta:
        model = Problem
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    # 只返回算法基本字段，排除反向字段避免循环
    algorithms = ma.Nested("AlgorithmSchema", many=True, exclude=("problem", "tools", "papers"))


class AlgorithmSchema(ma.SQLAlchemyAutoSchema):
    """算法实体的序列化，携带所属问题、工具摘要、文献摘要。"""

    class Meta:
        model = Algorithm
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    problem = ma.Nested("ProblemSchema", only=("id", "name"))
    tools = ma.Nested("ToolSchema", many=True, only=("id", "name", "version"))
    papers = ma.Nested("PaperSchema", many=True, only=("id", "title", "year", "doi"))


class LabSchema(ma.SQLAlchemyAutoSchema):
    """实验室实体序列化，附带工具摘要。"""

    class Meta:
        model = Lab
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    tools = ma.Nested("ToolSchema", many=True, only=("id", "name", "version"))


class ToolSchema(ma.SQLAlchemyAutoSchema):
    """工具实体序列化，包含所属算法、实验室与文献摘要。"""

    class Meta:
        model = Tool
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    algorithm = ma.Nested("AlgorithmSchema", only=("id", "name"))
    lab = ma.Nested("LabSchema", only=("id", "name"))
    papers = ma.Nested("PaperSchema", many=True, only=("id", "title", "year", "doi"))


class PaperSchema(ma.SQLAlchemyAutoSchema):
    """文献实体序列化，包含相关算法与工具摘要。"""

    class Meta:
        model = Paper
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    algorithms = ma.Nested("AlgorithmSchema", many=True, only=("id", "name"))
    tools = ma.Nested("ToolSchema", many=True, only=("id", "name", "version"))


class UserSchema(ma.SQLAlchemyAutoSchema):
    """用户实体序列化，密码哈希仅用于入库，不回传给前端。"""

    class Meta:
        model = User
        include_fk = True
        include_relationships = True
        load_instance = True
        sqla_session = db.session
        ordered = True
        unknown = EXCLUDE

    # load_only 确保响应中不返回密码哈希，避免信息泄露
    password_hash = fields.String(load_only=True)
