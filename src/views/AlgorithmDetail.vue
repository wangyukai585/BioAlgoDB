<template>
  <div class="page" v-if="algo">
    <header class="header">
      <div>
        <h2>{{ algo.name }}</h2>
        <p class="sub">Problem: {{ algo.problem?.name || 'Unknown' }}</p>
      </div>
      <div class="year" v-if="algo.year">Published: {{ algo.year }}</div>
    </header>

    <section class="section">
      <h3>Description</h3>
      <p class="desc">{{ algo.description || 'No description' }}</p>
    </section>

    <section class="section">
      <h3>Related Tools</h3>
      <ul>
        <li v-for="tool in algo.tools || []" :key="tool.id">
          {{ tool.name }} <span v-if="tool.version">(version: {{ tool.version }})</span>
        </li>
        <li v-if="!algo.tools || algo.tools.length === 0">No data</li>
      </ul>
    </section>

    <section class="section">
      <h3>References (Papers)</h3>
      <ul>
        <li v-for="paper in algo.papers || []" :key="paper.id">
          {{ paper.title }} <span v-if="paper.year">({{ paper.year }})</span>
          <span v-if="paper.doi"> DOI: {{ paper.doi }}</span>
        </li>
        <li v-if="!algo.papers || algo.papers.length === 0">No data</li>
      </ul>
    </section>
  </div>
  <div v-else class="loading">Loading...</div>
</template>

<script setup>
// 算法详情页：展示描述、流程占位图、工具和文献。
import { onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';
import { getAlgorithmDetail } from '@/api';

const route = useRoute();
const algo = ref(null);

const loadDetail = async () => {
  const id = route.params.id;
  if (!id) return;
  algo.value = await getAlgorithmDetail(id);
};

onMounted(loadDetail);
</script>

<style scoped>
.page {
  padding: 24px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.sub {
  margin: 4px 0 0;
  color: #666;
}
.year {
  color: #444;
  font-weight: 600;
}
.section {
  margin-bottom: 18px;
}
.desc {
  margin: 6px 0 0;
  color: #555;
  line-height: 1.5;
}
.flow-placeholder {
  margin-top: 8px;
  padding: 18px;
  border: 1px dashed #a0b3d9;
  border-radius: 10px;
  color: #586b8c;
  text-align: center;
  background: #f6f8fc;
}
ul {
  padding-left: 18px;
  color: #444;
}
.loading {
  padding: 24px;
  text-align: center;
}
</style>
