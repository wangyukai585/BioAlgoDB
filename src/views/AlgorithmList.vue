<template>
  <div class="page">
    <div class="filters">
      <input
        v-model="keyword"
        type="text"
        placeholder="Search algorithm name or description"
        @keyup.enter="loadAlgorithms"
      />
      <select v-model="selectedProblem" @change="loadAlgorithms">
        <option value="">All problems</option>
        <option v-for="p in problems" :key="p.id" :value="p.id">
          {{ p.name }}
        </option>
      </select>
      <button @click="loadAlgorithms">Search</button>
    </div>

    <div class="list">
      <div
        class="card"
        v-for="algo in algorithms"
        :key="algo.id"
        @click="goDetail(algo.id)"
      >
        <h3>{{ algo.name }}</h3>
        <p class="desc">{{ algo.description || 'No description' }}</p>
        <p class="meta">Problem: {{ algo.problem?.name || 'Unknown' }}</p>
        <p class="meta">Tools: {{ algo.tools?.length || 0 }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
// 算法列表/搜索页：支持关键字、问题筛选，点击进入详情。
import { onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { fetchProblems, searchAlgorithms } from '@/api';

const router = useRouter();
const route = useRoute();
const keyword = ref('');
const selectedProblem = ref('');
const problems = ref([]);
const algorithms = ref([]);

const loadProblems = async () => {
  problems.value = await fetchProblems();
};

const loadAlgorithms = async () => {
  const params = {};
  if (keyword.value.trim()) params.q = keyword.value.trim();
  if (selectedProblem.value) params.problem_id = selectedProblem.value;
  algorithms.value = await searchAlgorithms(params);
};

const goDetail = (id) => {
  router.push({ name: 'AlgorithmDetail', params: { id } });
};

onMounted(async () => {
  // 初始化时从路由查询参数填充搜索条件
  if (route.query.q) keyword.value = String(route.query.q);
  if (route.query.problem_id) selectedProblem.value = String(route.query.problem_id);
  await loadProblems();
  await loadAlgorithms();
});

// 监听路由查询参数变化，响应来自导航栏的搜索
watch(
  () => route.query,
  (q) => {
    keyword.value = q.q ? String(q.q) : '';
    selectedProblem.value = q.problem_id ? String(q.problem_id) : '';
    loadAlgorithms();
  },
  { deep: true }
);
</script>

<style scoped>
.page {
  padding: 24px;
}
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
  align-items: center;
}
.filters input,
.filters select {
  padding: 8px 10px;
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  min-width: 200px;
}
.filters button {
  padding: 8px 14px;
  background: #4a7df2;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}
.filters button:hover {
  background: #3d6ada;
}
.list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 16px;
}
.card {
  border: 1px solid #e5eaf5;
  background: #fff;
  border-radius: 10px;
  padding: 14px;
  cursor: pointer;
  transition: box-shadow 0.2s ease;
}
.card:hover {
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
}
.card h3 {
  margin: 0 0 8px;
}
.desc {
  margin: 0 0 8px;
  color: #555;
  min-height: 40px;
}
.meta {
  margin: 2px 0;
  color: #666;
  font-size: 13px;
}
</style>
