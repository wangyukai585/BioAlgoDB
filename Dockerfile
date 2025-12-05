# 后端 Dockerfile：Python 3.9-slim，安装依赖并用 gunicorn 启动 Flask
FROM python:3.9-slim

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 安装构建依赖（bcrypt 需要编译），完毕后清理缓存
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 安装项目所需的 Python 包
RUN pip install --no-cache-dir \
    flask \
    flask-restful \
    flask-sqlalchemy \
    flask-marshmallow \
    marshmallow-sqlalchemy \
    PyMySQL \
    flask-jwt-extended \
    flask-cors \
    werkzeug \
    cryptography \
    bcrypt \
    gunicorn

# 拷贝代码
COPY . /app

# 默认使用 gunicorn 运行 Flask 应用
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
