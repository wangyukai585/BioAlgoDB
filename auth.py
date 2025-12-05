"""认证与权限模块：注册、登录、管理员鉴权（中文注释版）。"""

from functools import wraps

from flask import request
from flask_restful import Resource
from flask_jwt_extended import (
    create_access_token,
    get_jwt,
    verify_jwt_in_request,
)
from werkzeug.security import check_password_hash, generate_password_hash
import bcrypt  # 兼容早期以 bcrypt 存储的种子数据

from models import User, db
from schemas import UserSchema
from sqlalchemy.exc import IntegrityError

user_schema = UserSchema()


def admin_required(fn):
    """管理员权限校验：需携带 JWT 且角色为 admin。"""

    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        claims = get_jwt()
        if claims.get("role") != "admin":
            return {"message": "需要管理员权限"}, 403
        return fn(*args, **kwargs)

    return wrapper


class RegisterResource(Resource):
    """用户注册接口，默认创建普通用户角色。"""

    def post(self):
        data = request.get_json() or {}
        username = data.get("username")
        email = data.get("email")
        password = data.get("password")
        if not username or not email or not password:
            return {"message": "username、email、password 均为必填"}, 400

        if User.query.filter((User.username == username) | (User.email == email)).first():
            return {"message": "用户名或邮箱已存在"}, 409

        hashed = generate_password_hash(password)
        user = User(username=username, email=email, password_hash=hashed, role="user")
        db.session.add(user)
        try:
            db.session.commit()
        except IntegrityError:
            # 捕获数据库唯一约束等错误，避免抛出 500
            db.session.rollback()
            return {"message": "用户名或邮箱已存在"}, 409

        return user_schema.dump(user), 201


class LoginResource(Resource):
    """用户登录接口，校验密码后签发 JWT。"""

    def post(self):
        data = request.get_json() or {}
        username = data.get("username")
        password = data.get("password")
        if not username or not password:
            return {"message": "username 与 password 为必填"}, 400

        user = User.query.filter_by(username=username).first()
        if not user:
            return {"message": "用户名或密码错误"}, 401

        # 兼容可能的非默认哈希格式（如旧的 bcrypt 存量），避免抛出未捕获异常导致 500。
        try:
            password_ok = check_password_hash(user.password_hash, password)
        except ValueError:
            # 如果是 bcrypt 哈希，使用 bcrypt 校验
            if user.password_hash.startswith("$2a$") or user.password_hash.startswith("$2b$"):
                try:
                    password_ok = bcrypt.checkpw(password.encode("utf-8"), user.password_hash.encode("utf-8"))
                except Exception:
                    return {"message": "密码哈希格式不兼容，请重置密码或重新设置账户密码"}, 400
            else:
                return {"message": "密码哈希格式不兼容，请重置密码或重新设置账户密码"}, 400

        if not password_ok:
            return {"message": "用户名或密码错误"}, 401

        access_token = create_access_token(
            identity=user.id,
            additional_claims={"role": user.role, "username": user.username},
        )
        return {"access_token": access_token, "role": user.role, "username": user.username}
