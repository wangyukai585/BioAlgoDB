<template>
  <div class="login-page">
    <div class="card">
      <h2>Register</h2>
      <form @submit.prevent="handleRegister">
        <label>
          Username
          <input v-model="form.username" type="text" placeholder="Enter username" required />
        </label>
        <label>
          Email
          <input v-model="form.email" type="email" placeholder="Enter email" required />
        </label>
        <label>
          Password
          <input v-model="form.password" type="password" placeholder="Enter password" required />
        </label>
        <button type="submit" :disabled="loading">
          {{ loading ? 'Registering...' : 'Register' }}
        </button>
        <p v-if="error" class="error">{{ error }}</p>
        <p v-if="success" class="success">{{ success }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
// 注册页：提交后创建用户，成功后提示并跳转登录。
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { register } from '@/api';

const router = useRouter();
const form = reactive({
  username: '',
  email: '',
  password: '',
});
const loading = ref(false);
const error = ref('');
const success = ref('');

const handleRegister = async () => {
  loading.value = true;
  error.value = '';
  success.value = '';
  try {
    await register({
      username: form.username,
      email: form.email,
      password: form.password,
    });
    success.value = 'Registration successful, please login';
    setTimeout(() => router.push('/login'), 800);
  } catch (e) {
    error.value = e.response?.data?.message || 'Registration failed, please try again';
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
  width: 340px;
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
.success {
  color: #2e8b57;
  font-size: 13px;
  text-align: center;
}
</style>
