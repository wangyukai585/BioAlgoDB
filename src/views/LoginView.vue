<template>
  <div class="login-page">
    <div class="card">
      <h2>Login</h2>
      <form @submit.prevent="handleLogin">
        <label>
          Username
          <input v-model="form.username" type="text" placeholder="Enter username" required />
        </label>
        <label>
          Password
          <input v-model="form.password" type="password" placeholder="Enter password" required />
        </label>
        <button type="submit" :disabled="loading">
          {{ loading ? 'Signing in...' : 'Login' }}
        </button>
        <p v-if="error" class="error">{{ error }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
// 登录页：提交后保存 Token，解析角色，并跳转。
import { reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { login } from '@/api';
import { TOKEN_KEY } from '@/api';
import { useUserStore } from '@/stores/user';

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();

const form = reactive({
  username: '',
  password: '',
});
const loading = ref(false);
const error = ref('');

const handleLogin = async () => {
  loading.value = true;
  error.value = '';
  try {
    const res = await login({ username: form.username, password: form.password });
    const token = res.access_token;
    localStorage.setItem(TOKEN_KEY, token);
    userStore.setToken(token);
    // 登录成功后跳转到来源或首页
    const redirect = route.query.redirect || '/';
    router.push(redirect);
  } catch (e) {
    error.value = e.response?.data?.message || 'Login failed, please check username or password';
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-page {
  min-height: 70vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24px;
}
.card {
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
  width: 320px;
}
h2 {
  margin: 0 0 16px;
  text-align: center;
}
form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
label {
  display: flex;
  flex-direction: column;
  font-size: 14px;
  color: #555;
}
input {
  padding: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  margin-top: 4px;
}
button {
  padding: 10px;
  background: #1f4b99;
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}
button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
.error {
  color: #d93025;
  font-size: 13px;
  text-align: center;
}
</style>
