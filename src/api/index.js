// API 函数集合：依赖统一封装的 Axios 实例。
import http, { TOKEN_KEY } from './axios';

// 获取首页统计数据
export const fetchStats = () => http.get('/api/stats').then((res) => res.data);

// 获取问题列表（筛选用）
export const fetchProblems = () => http.get('/api/problems').then((res) => res.data);

// 搜索/列表算法，支持关键字和问题筛选
export const searchAlgorithms = (params = {}) =>
  http.get('/api/algorithms', { params }).then((res) => res.data);

// 获取算法详情
export const getAlgorithmDetail = (id) =>
  http.get(`/api/algorithms/${id}`).then((res) => res.data);

// 登录，返回 token 等信息
export const login = (payload) => http.post('/api/auth/login', payload).then((res) => res.data);

// 注册（可选）
export const register = (payload) => http.post('/api/auth/register', payload).then((res) => res.data);

export { TOKEN_KEY };
