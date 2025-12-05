# BioAlgoDB

Bioinformatics Algorithms Database — Yukai Wang（数据库原理课程项目）。收录典型生物信息学问题、算法、工具、实验室与文献，提供 REST API 与 Vue 前端，支持统计、列表与详情浏览。

## 后端部署（Flask）
1) 创建虚拟环境  
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .\.venv\Scripts\activate
```
2) 安装依赖  
```bash
pip install -r requirements.txt
```
`requirements.txt` 内容：  
```
flask
flask-restful
flask-sqlalchemy
flask-marshmallow
marshmallow-sqlalchemy
PyMySQL
flask-jwt-extended
flask-cors
werkzeug
bcrypt
cryptography
```
3) 环境变量  
```bash
export DATABASE_URL="mysql+pymysql://<user>:<pass>@localhost:3306/bioalgodb?charset=utf8mb4"
export JWT_SECRET_KEY="<random-secret>"
export FLASK_APP=app.py
```
4) 初始化数据库  
- 导入脚本：`mysql -u<user> -p<pass> bioalgodb < db/init.sql`（建表 + 种子数据）  
- 或使用 Docker Compose，在空数据卷首启时自动执行 `db/init.sql`。

5) 运行后端  
```bash
flask run  # 或 python app.py
```

## 前端部署（Vue 3 + Vite）
1) 安装依赖  
```bash
npm install
```
2) 开发模式  
```bash
npm run dev
```
3) 生产构建  
```bash
npm run build
```
如需指定后端地址，设置 `VITE_API_BASE_URL`；默认使用相对路径 `/api` 通过 Nginx 反向代理。

## API 简述
- `GET /api/health` 健康检查  
- `GET /api/stats` 统计与按问题分类的算法数量  
- `GET /api/problems` 问题列表  
- `GET /api/algorithms?q=&problem_id=` 算法列表/搜索  
- `GET /api/algorithms/<id>` 算法详情（含工具、文献、问题名）  
- `GET /api/tools`、`GET /api/labs` 工具与实验室列表  
- 认证：`POST /api/auth/register` 注册；`POST /api/auth/login` 登录返回 JWT  
- 管理员（需 Authorization: Bearer <token>）：`POST/PUT/DELETE /api/algorithms`、`/api/tools`、`/api/labs`

## 3NF 说明
- 主键唯一，非键属性仅依赖主键，无部分依赖；  
- 无传递依赖，属性不依赖其他非键属性（如 paper 的 doi/journal 仅依赖 paper.id；tool 元数据仅依赖 tool.id）；  
- 多对多关系使用连接表复合主键（algorithm_paper、tool_paper），避免冗余与异常。  
因此各关系满足第三范式（3NF）。

## Docker
`docker-compose.yml` 启动 MySQL + backend(gunicorn) + nginx(服务 dist)。流程：  
```bash
npm run build            # 先构建前端
docker compose up -d     # 空数据卷会自动导入 db/init.sql
```
如需清空数据，可 `docker compose down -v`（删除数据卷，谨慎）。***
