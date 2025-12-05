<template>
  <nav class="nav">
    <div class="brand" @click="goHome">BioAlgoDB</div>

    <div class="links">
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/algorithms">Algorithms</RouterLink>
      <RouterLink v-if="isAdmin" :to="{ path: '/algorithms', query: { manage: 1 } }">Data Admin</RouterLink>
    </div>

    <div class="search">
      <input
        v-model="searchKey"
        type="text"
        placeholder="Search algorithms..."
        @keyup.enter="doSearch"
      />
    </div>

    <div class="user">
      <template v-if="isLoggedIn">
        <span class="username">{{ username }}</span>
        <button class="link" @click="logout">Logout</button>
      </template>
      <template v-else>
        <RouterLink to="/login">Login</RouterLink>
        <RouterLink to="/register" class="register">Register</RouterLink>
      </template>
    </div>
  </nav>
</template>

<script setup>
// 顶部导航：搜索跳转、登录状态显示、管理员入口。
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user';

const router = useRouter();
const userStore = useUserStore();
const { isLoggedIn, isAdmin, username } = storeToRefs(userStore);
const searchKey = ref('');

const doSearch = () => {
  router.push({ name: 'AlgorithmList', query: searchKey.value ? { q: searchKey.value } : {} });
};

const goHome = () => router.push('/');

const logout = () => {
  userStore.logout();
  router.push('/login');
};
</script>

<style scoped>
.nav {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 16px;
  background: #1f4b99;
  color: #fff;
  position: sticky;
  top: 0;
  z-index: 10;
}
.brand {
  font-weight: 700;
  letter-spacing: 0.5px;
  cursor: pointer;
}
.links {
  display: flex;
  gap: 12px;
}
.links a {
  color: #e7efff;
  text-decoration: none;
}
.links a.router-link-active {
  font-weight: 700;
  text-decoration: underline;
}
.search input {
  padding: 6px 10px;
  border-radius: 6px;
  border: none;
  min-width: 180px;
}
.user {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 10px;
}
.username {
  color: #e7efff;
}
.link {
  background: transparent;
  border: 1px solid #e7efff;
  color: #e7efff;
  padding: 4px 10px;
  border-radius: 6px;
  cursor: pointer;
}
.link:hover {
  background: rgba(255, 255, 255, 0.12);
}
.register {
  font-weight: 700;
}
</style>
