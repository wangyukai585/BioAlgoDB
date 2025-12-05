// 用户状态管理：保存 token、用户名、角色，支持登出和解析 JWT。
import { defineStore } from 'pinia';
import { TOKEN_KEY } from '@/api';

const decodeToken = (token) => {
  try {
    const base64Payload = token.split('.')[1];
    const normalized = base64Payload.replace(/-/g, '+').replace(/_/g, '/');
    const payload = JSON.parse(atob(normalized));
    return payload || {};
  } catch (e) {
    console.warn('JWT 解析失败', e);
    return {};
  }
};

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    username: '',
    role: '',
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
    isAdmin: (state) => state.role === 'admin',
  },
  actions: {
    setToken(token) {
      this.token = token;
      if (token) {
        localStorage.setItem(TOKEN_KEY, token);
      } else {
        localStorage.removeItem(TOKEN_KEY);
      }
      this.setUserFromToken(token);
    },
    setUserFromToken(token) {
      if (!token) {
        this.username = '';
        this.role = '';
        return;
      }
      const payload = decodeToken(token);
      this.username = payload?.username || '';
      this.role = payload?.role || '';
    },
    logout() {
      this.token = '';
      this.username = '';
      this.role = '';
      localStorage.removeItem(TOKEN_KEY);
    },
  },
});
