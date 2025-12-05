// 路由配置：首页、算法列表、算法详情。
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  { path: '/', name: 'Home', component: () => import('@/views/HomeView.vue') },
  { path: '/algorithms', name: 'AlgorithmList', component: () => import('@/views/AlgorithmList.vue') },
  { path: '/algorithms/:id', name: 'AlgorithmDetail', component: () => import('@/views/AlgorithmDetail.vue') },
  { path: '/login', name: 'Login', component: () => import('@/views/LoginView.vue') },
  { path: '/register', name: 'Register', component: () => import('@/views/RegisterView.vue') },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
