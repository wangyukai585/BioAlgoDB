// Axios 实例封装：自动附加 Token，处理 401 跳转登录。
import axios from 'axios';
import router from '@/router';

export const TOKEN_KEY = 'token';

const apiBaseURL = import.meta.env.VITE_API_BASE_URL || '';

const http = axios.create({
  baseURL: apiBaseURL,
  timeout: 10000,
});

// 请求拦截：如果本地有 Token，则写入 Authorization 头。
http.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(TOKEN_KEY);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

// 响应拦截：遇到 401 清除 Token 并跳转登录页。
http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem(TOKEN_KEY);
      const current = router.currentRoute.value;
      const redirect = current?.fullPath || '/';
      router.push({ name: 'Login', query: { redirect } });
    }
    return Promise.reject(error);
  },
);

export default http;
