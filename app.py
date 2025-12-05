"""Flask 应用入口：初始化数据库、序列化、JWT、CORS 以及 RESTful 路由（中文注释版）。"""

from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_restful import Api

from auth import LoginResource, RegisterResource
from config import Config
from models import db
from resources import (
    AlgorithmDetailResource,
    AlgorithmListResource,
    HealthResource,
    LabDetailResource,
    LabListResource,
    ProblemListResource,
    StatsResource,
    ToolDetailResource,
    ToolListResource,
)
from schemas import ma


def register_routes(api: Api) -> None:
    """统一注册所有 RESTful 路由，便于集中管理。"""

    # 基础与统计
    api.add_resource(HealthResource, "/api/health")
    api.add_resource(StatsResource, "/api/stats")
    api.add_resource(ProblemListResource, "/api/problems")

    # 算法接口（含搜索、详情与管理员增删改）
    api.add_resource(AlgorithmListResource, "/api/algorithms")
    api.add_resource(AlgorithmDetailResource, "/api/algorithms/<int:algorithm_id>")

    # 工具与实验室 CRUD
    api.add_resource(ToolListResource, "/api/tools")
    api.add_resource(ToolDetailResource, "/api/tools/<int:tool_id>")
    api.add_resource(LabListResource, "/api/labs")
    api.add_resource(LabDetailResource, "/api/labs/<int:lab_id>")

    # 认证接口
    api.add_resource(RegisterResource, "/api/auth/register")
    api.add_resource(LoginResource, "/api/auth/login")


def create_app(config_class=Config) -> Flask:
    """应用工厂：加载配置并初始化扩展。"""

    app = Flask(__name__)
    app.config.from_object(config_class)

    # 初始化数据库与序列化扩展
    db.init_app(app)
    ma.init_app(app)

    # 初始化 JWT
    JWTManager(app)

    # 开启跨域，默认允许所有来源访问 /api/*；可在环境变量中配置 CORS_ORIGINS。
    CORS(app, resources={r"/api/*": {"origins": app.config.get("CORS_ORIGINS", "*")}})

    # 注册 RESTful 接口
    api = Api(app)
    register_routes(api)

    @app.route("/")
    def index():
        """根路由返回服务基本信息。"""

        return {"service": "BioAlgoDB API", "status": "ok"}

    # 全局 404 处理，统一返回 JSON
    @app.errorhandler(404)
    def handle_not_found(_):
        return jsonify({"message": "资源未找到"}), 404

    return app


# 默认创建应用实例，便于 flask run 直接使用
app = create_app()

if __name__ == "__main__":
    # 开启调试模式便于开发调试；生产环境请关闭或交由 WSGI 容器管理。
    app.run(debug=True)
