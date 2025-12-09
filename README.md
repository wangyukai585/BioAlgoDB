# BioAlgoDB

Bioinformatics Algorithms Database 收录典型生物信息学问题、算法、工具、实验室与文献，提供 REST API 与 Vue 前端，支持统计、列表与详情浏览。

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

## Docker（强烈推荐，无需本地安装 MySQL）
`docker-compose.yml` 启动 MySQL + backend(gunicorn) + nginx(服务 dist)，一键起全栈。

步骤：
1) 构建前端产物（Nginx 静态服务）  
```bash
npm install          # 首次需要
npm run build        # 生成 dist/
```
2) 启动所有容器  
```bash
docker compose up -d
```
- 首次且数据卷为空时，会自动导入 `db/init.sql`（建表+种子数据）。
- 后端镜像按 Dockerfile 构建，Nginx 用官方镜像挂载 dist 与 nginx.conf。

3) 访问  
- 前端：http://localhost  
- API（经 Nginx 代理）：http://localhost/api/health , /api/stats 等

4) 常用命令  
- 查看状态：`docker compose ps`  
- 查看日志：`docker compose logs backend` / `docker compose logs db` / `docker compose logs frontend`  
- 重启服务：`docker compose restart backend frontend`（db 通常无需重启）

5) 重置数据（谨慎，会删除数据库卷）  
```bash
docker compose down -v
docker compose up -d
```

### 从 GitHub 拉取并一键运行（老师视角）
```bash
# 1) 拉取代码
git clone https://github.com/wangyukai585/BioAlgoDB.git
cd BioAlgoDB

# 2) 构建前端
npm install
npm run build

# 3) 启动全栈（MySQL + 后端 + Nginx）
docker compose up -d

# 4) 访问
# 前端：http://localhost
# API 示例：http://localhost/api/health , http://localhost/api/stats
```
首次启动若数据卷为空，会自动导入 `db/init.sql`。若需重置数据，可执行 `docker compose down -v` 后再 `docker compose up -d`。***
