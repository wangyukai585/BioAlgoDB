"""应用全局配置：数据库连接与 SQLAlchemy 行为设置（中文注释版）。"""

import os


class Config:
    """Flask/SQLAlchemy 的基础配置类。"""

    # 优先读取环境变量 DATABASE_URL，便于在开发/生产切换；默认指向本地 MySQL。
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://bioalgodb_user:password@localhost:3306/bioalgodb?charset=utf8mb4",
    )

    # 关闭事件通知，减少无用开销。
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # pre_ping 避免连接池中的陈旧连接导致错误。
    SQLALCHEMY_ENGINE_OPTIONS = {"pool_pre_ping": True}

    # 保持 JSON 输出字段顺序，与定义顺序一致便于前端调试。
    JSON_SORT_KEYS = False

    # JWT 密钥：请在环境中覆盖 JWT_SECRET_KEY；默认仅用于本地开发。
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev-secret-change-me")
    # 允许前端跨域携带的头部自动处理（由 CORS 库完成，这里预留配置位）。
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*")
