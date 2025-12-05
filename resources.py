"""RESTful 资源定义：统计、查询、CRUD 及权限控制（中文注释版）。"""

from functools import wraps

from flask import request
from flask_restful import Resource
from sqlalchemy import or_, text

from auth import admin_required
from models import Algorithm, Lab, Problem, Tool, db
from schemas import AlgorithmSchema, LabSchema, ProblemSchema, ToolSchema

# 预生成常用 Schema，减少重复实例化开销
problem_schema = ProblemSchema(many=True)
algorithm_schema = AlgorithmSchema(many=True)
algorithm_detail_schema = AlgorithmSchema()
tool_schema = ToolSchema(many=True)
tool_detail_schema = ToolSchema()
lab_schema = LabSchema(many=True)
lab_detail_schema = LabSchema()


class HealthResource(Resource):
    """健康检查，验证服务可用性。"""

    def get(self):
        return {"status": "ok"}


class StatsResource(Resource):
    """首页统计：算法/工具/论文总数，以及按问题分类的算法数量。"""

    def get(self):
        algorithm_count = db.session.query(db.func.count(Algorithm.id)).scalar() or 0
        tool_count = db.session.query(db.func.count(Tool.id)).scalar() or 0
        # 论文数量通过直接 COUNT；不强制导入 Paper 模型，保持依赖简洁。
        paper_count = db.session.execute(text("SELECT COUNT(*) FROM paper")).scalar() or 0

        problem_alg_counts = (
            db.session.query(Problem.id, Problem.name, db.func.count(Algorithm.id))
            .outerjoin(Algorithm, Algorithm.problem_id == Problem.id)
            .group_by(Problem.id, Problem.name)
            .all()
        )
        by_problem = [
            {"problem_id": pid, "problem_name": name, "algorithm_count": count}
            for pid, name, count in problem_alg_counts
        ]

        return {
            "algorithm_count": algorithm_count,
            "tool_count": tool_count,
            "paper_count": paper_count,
            "algorithm_by_problem": by_problem,
        }


class ProblemListResource(Resource):
    """问题列表接口，返回全部问题及关联算法摘要。"""

    def get(self):
        problems = Problem.query.order_by(Problem.name.asc()).all()
        return problem_schema.dump(problems)


class AlgorithmListResource(Resource):
    """算法列表/搜索接口；支持按关键词或问题筛选；POST 需管理员。"""

    method_decorators = {"post": [admin_required]}

    def get(self):
        keyword = request.args.get("q") or request.args.get("keyword")
        problem_id = request.args.get("problem_id", type=int)

        query = Algorithm.query
        if keyword:
            like = f"%{keyword}%"
            query = query.filter(or_(Algorithm.name.like(like), Algorithm.description.like(like)))
        if problem_id:
            query = query.filter(Algorithm.problem_id == problem_id)

        algorithms = query.order_by(Algorithm.name.asc()).all()
        return algorithm_schema.dump(algorithms)

    def post(self):
        data = request.get_json() or {}
        name = data.get("name")
        problem_id = data.get("problem_id")
        if not name or not problem_id:
            return {"message": "name 与 problem_id 为必填"}, 400

        exists = Algorithm.query.filter_by(name=name).first()
        if exists:
            return {"message": "算法名称已存在"}, 409

        alg = Algorithm(
            name=name,
            problem_id=problem_id,
            description=data.get("description"),
            year=data.get("year"),
        )
        db.session.add(alg)
        db.session.commit()
        return algorithm_detail_schema.dump(alg), 201


class AlgorithmDetailResource(Resource):
    """算法详情；GET 开放，PUT/DELETE 需管理员。"""

    method_decorators = {"put": [admin_required], "delete": [admin_required]}

    def get(self, algorithm_id: int):
        alg = Algorithm.query.get(algorithm_id)
        if not alg:
            return {"message": "未找到该算法"}, 404
        return algorithm_detail_schema.dump(alg)

    def put(self, algorithm_id: int):
        alg = Algorithm.query.get(algorithm_id)
        if not alg:
            return {"message": "未找到该算法"}, 404

        data = request.get_json() or {}
        if "name" in data:
            # 校验重名
            dup = Algorithm.query.filter(Algorithm.id != algorithm_id, Algorithm.name == data["name"]).first()
            if dup:
                return {"message": "算法名称已存在"}, 409
            alg.name = data["name"]
        if "description" in data:
            alg.description = data["description"]
        if "year" in data:
            alg.year = data["year"]
        if "problem_id" in data:
            alg.problem_id = data["problem_id"]

        db.session.commit()
        return algorithm_detail_schema.dump(alg)

    def delete(self, algorithm_id: int):
        alg = Algorithm.query.get(algorithm_id)
        if not alg:
            return {"message": "未找到该算法"}, 404
        db.session.delete(alg)
        db.session.commit()
        return {"message": "删除成功"}


class ToolListResource(Resource):
    """工具列表/新增；GET 开放，POST 需管理员。"""

    method_decorators = {"post": [admin_required]}

    def get(self):
        tools = Tool.query.order_by(Tool.name.asc()).all()
        return tool_schema.dump(tools)

    def post(self):
        data = request.get_json() or {}
        name = data.get("name")
        algorithm_id = data.get("algorithm_id")
        if not name or not algorithm_id:
            return {"message": "name 与 algorithm_id 为必填"}, 400

        dup = Tool.query.filter_by(name=name).first()
        if dup:
            return {"message": "工具名称已存在"}, 409

        tool = Tool(
            name=name,
            algorithm_id=algorithm_id,
            lab_id=data.get("lab_id"),
            version=data.get("version"),
            description=data.get("description"),
            website=data.get("website"),
            license=data.get("license"),
        )
        db.session.add(tool)
        db.session.commit()
        return tool_detail_schema.dump(tool), 201


class ToolDetailResource(Resource):
    """工具详情查看/修改/删除；PUT/DELETE 需管理员。"""

    method_decorators = {"put": [admin_required], "delete": [admin_required]}

    def get(self, tool_id: int):
        tool = Tool.query.get(tool_id)
        if not tool:
            return {"message": "未找到该工具"}, 404
        return tool_detail_schema.dump(tool)

    def put(self, tool_id: int):
        tool = Tool.query.get(tool_id)
        if not tool:
            return {"message": "未找到该工具"}, 404

        data = request.get_json() or {}
        if "name" in data:
            dup = Tool.query.filter(Tool.id != tool_id, Tool.name == data["name"]).first()
            if dup:
                return {"message": "工具名称已存在"}, 409
            tool.name = data["name"]
        for field in ("version", "description", "website", "license", "algorithm_id", "lab_id"):
            if field in data:
                setattr(tool, field, data[field])

        db.session.commit()
        return tool_detail_schema.dump(tool)

    def delete(self, tool_id: int):
        tool = Tool.query.get(tool_id)
        if not tool:
            return {"message": "未找到该工具"}, 404
        db.session.delete(tool)
        db.session.commit()
        return {"message": "删除成功"}


class LabListResource(Resource):
    """实验室列表/新增；GET 开放，POST 需管理员。"""

    method_decorators = {"post": [admin_required]}

    def get(self):
        labs = Lab.query.order_by(Lab.name.asc()).all()
        return lab_schema.dump(labs)

    def post(self):
        data = request.get_json() or {}
        name = data.get("name")
        if not name:
            return {"message": "name 为必填"}, 400
        dup = Lab.query.filter_by(name=name).first()
        if dup:
            return {"message": "实验室名称已存在"}, 409

        lab = Lab(
            name=name,
            institution=data.get("institution"),
            country=data.get("country"),
            website=data.get("website"),
            description=data.get("description"),
        )
        db.session.add(lab)
        db.session.commit()
        return lab_detail_schema.dump(lab), 201


class LabDetailResource(Resource):
    """实验室详情查看/修改/删除；PUT/DELETE 需管理员。"""

    method_decorators = {"put": [admin_required], "delete": [admin_required]}

    def get(self, lab_id: int):
        lab = Lab.query.get(lab_id)
        if not lab:
            return {"message": "未找到该实验室"}, 404
        return lab_detail_schema.dump(lab)

    def put(self, lab_id: int):
        lab = Lab.query.get(lab_id)
        if not lab:
            return {"message": "未找到该实验室"}, 404

        data = request.get_json() or {}
        if "name" in data:
            dup = Lab.query.filter(Lab.id != lab_id, Lab.name == data["name"]).first()
            if dup:
                return {"message": "实验室名称已存在"}, 409
            lab.name = data["name"]
        for field in ("institution", "country", "website", "description"):
            if field in data:
                setattr(lab, field, data[field])

        db.session.commit()
        return lab_detail_schema.dump(lab)

    def delete(self, lab_id: int):
        lab = Lab.query.get(lab_id)
        if not lab:
            return {"message": "未找到该实验室"}, 404
        db.session.delete(lab)
        db.session.commit()
        return {"message": "删除成功"}
