<template>
  <div class="layout">
    <NavBar />
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
// 根组件：使用 NavBar 统一处理导航与搜索。
import NavBar from '@/components/NavBar.vue';
</script>

<style scoped>
.layout {
  min-height: 100vh;
  background: #f5f7fb;
  color: #1f2d3d;
}
.content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 18px;
}
</style>
