"""SQLAlchemy ORM 模型定义：对应数据库表结构与关系映射（中文注释版）。"""

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


# 多对多中间表：算法 ↔ 文献
algorithm_paper = db.Table(
    "algorithm_paper",
    db.Column("algorithm_id", db.BigInteger, db.ForeignKey("algorithm.id"), primary_key=True),
    db.Column("paper_id", db.BigInteger, db.ForeignKey("paper.id"), primary_key=True),
    db.Index("idx_algorithm_paper_algorithm", "algorithm_id"),
    db.Index("idx_algorithm_paper_paper", "paper_id"),
    mysql_charset="utf8mb4",
    mysql_collate="utf8mb4_unicode_ci",
)

# 多对多中间表：工具 ↔ 文献
tool_paper = db.Table(
    "tool_paper",
    db.Column("tool_id", db.BigInteger, db.ForeignKey("tool.id"), primary_key=True),
    db.Column("paper_id", db.BigInteger, db.ForeignKey("paper.id"), primary_key=True),
    db.Index("idx_tool_paper_tool", "tool_id"),
    db.Index("idx_tool_paper_paper", "paper_id"),
    mysql_charset="utf8mb4",
    mysql_collate="utf8mb4_unicode_ci",
)


class Problem(db.Model):
    """生物学问题实体，例如序列比对、基因组组装。"""

    __tablename__ = "problem"
    __table_args__ = (
        db.UniqueConstraint("name", name="uq_problem_name"),
        db.Index("idx_problem_name", "name"),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)

    # 关联：一个问题下有多个算法
    algorithms = db.relationship("Algorithm", back_populates="problem", lazy="select")

    def __repr__(self) -> str:
        return f"<Problem {self.id} {self.name}>"


class Algorithm(db.Model):
    """算法实体，指向所属问题，并可关联工具和文献。"""

    __tablename__ = "algorithm"
    __table_args__ = (
        db.UniqueConstraint("name", name="uq_algorithm_name"),
        db.Index("idx_algorithm_name", "name"),
        # 对描述做前缀索引，满足模糊搜索需求。
        db.Index("idx_algorithm_description", "description", mysql_length=255),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    problem_id = db.Column(
        db.BigInteger, db.ForeignKey("problem.id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False
    )
    name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    year = db.Column(db.Integer)

    # 关联：算法属于一个问题
    problem = db.relationship("Problem", back_populates="algorithms", lazy="joined")
    # 关联：算法下有多个工具
    tools = db.relationship("Tool", back_populates="algorithm", lazy="select")
    # 关联：算法对应多篇文献（多对多）
    papers = db.relationship("Paper", secondary=algorithm_paper, back_populates="algorithms", lazy="select")

    def __repr__(self) -> str:
        return f"<Algorithm {self.id} {self.name}>"


class Lab(db.Model):
    """实验室/机构实体，负责开发或维护工具。"""

    __tablename__ = "lab"
    __table_args__ = (
        db.UniqueConstraint("name", name="uq_lab_name"),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    institution = db.Column(db.String(255))
    country = db.Column(db.String(100))
    website = db.Column(db.String(255))
    description = db.Column(db.Text)

    # 关联：一个实验室可维护多个工具
    tools = db.relationship("Tool", back_populates="lab", lazy="select")

    def __repr__(self) -> str:
        return f"<Lab {self.id} {self.name}>"


class Tool(db.Model):
    """工具实体，基于算法实现，可关联实验室与文献。"""

    __tablename__ = "tool"
    __table_args__ = (
        db.UniqueConstraint("name", name="uq_tool_name"),
        db.Index("idx_tool_algorithm", "algorithm_id"),
        db.Index("idx_tool_lab", "lab_id"),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    algorithm_id = db.Column(
        db.BigInteger, db.ForeignKey("algorithm.id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False
    )
    lab_id = db.Column(
        db.BigInteger, db.ForeignKey("lab.id", onupdate="CASCADE", ondelete="SET NULL"), nullable=True
    )
    name = db.Column(db.String(255), nullable=False)
    version = db.Column(db.String(50))
    description = db.Column(db.Text)
    website = db.Column(db.String(255))
    license = db.Column(db.String(100))

    # 关联：工具对应一个算法
    algorithm = db.relationship("Algorithm", back_populates="tools", lazy="joined")
    # 关联：工具由某个实验室维护（可空）
    lab = db.relationship("Lab", back_populates="tools", lazy="joined")
    # 关联：工具相关文献（多对多）
    papers = db.relationship("Paper", secondary=tool_paper, back_populates="tools", lazy="select")

    def __repr__(self) -> str:
        return f"<Tool {self.id} {self.name}>"


class Paper(db.Model):
    """文献实体，记录标题、期刊、DOI 等，关联算法与工具。"""

    __tablename__ = "paper"
    __table_args__ = (
        db.UniqueConstraint("doi", name="uq_paper_doi"),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    year = db.Column(db.Integer)
    doi = db.Column(db.String(128))
    journal = db.Column(db.String(255))
    authors = db.Column(db.Text)

    # 关联：文献可对应多个算法和工具
    algorithms = db.relationship("Algorithm", secondary=algorithm_paper, back_populates="papers", lazy="select")
    tools = db.relationship("Tool", secondary=tool_paper, back_populates="papers", lazy="select")

    def __repr__(self) -> str:
        return f"<Paper {self.id} {self.title}>"


class User(db.Model):
    """用户实体，支持角色区分，密码存储为哈希。"""

    __tablename__ = "user"
    __table_args__ = (
        db.UniqueConstraint("username", name="uq_user_username"),
        db.UniqueConstraint("email", name="uq_user_email"),
        db.Index("idx_user_role", "role"),
        {"mysql_charset": "utf8mb4", "mysql_collate": "utf8mb4_unicode_ci"},
    )

    id = db.Column(db.BigInteger, primary_key=True)
    username = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.Enum("admin", "user", name="role_enum"), nullable=False, default="user")
    created_at = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)

    def __repr__(self) -> str:
        return f"<User {self.id} {self.username}>"
