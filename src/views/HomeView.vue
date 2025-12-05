<template>
  <div class="home">
    <header class="hero">
      <h1>BioAlgoDB</h1>
      <p>Bioinformatics Algorithms Database — Yukai Wang (Database Principles Project)</p>
    </header>

    <section class="stats">
      <div class="stat-card" v-for="item in statCards" :key="item.label">
        <div class="stat-value">{{ item.value }}</div>
        <div class="stat-label">{{ item.label }}</div>
      </div>
    </section>

    <section class="chart-section">
      <h2>Algorithm distribution by problem</h2>
      <div v-if="(chartData?.length || 0) > 0" ref="chartRef" class="chart"></div>
      <div v-else class="chart-placeholder">No data available</div>
    </section>
  </div>
</template>

<script setup>
// 首页：展示标题、统计数字和按问题分类的算法分布图。
import { onMounted, onBeforeUnmount, ref, nextTick, watch } from 'vue';
import * as echarts from 'echarts';
import { fetchStats } from '@/api';

const statCards = ref([
  { label: 'Algorithms', value: 0 },
  { label: 'Tools', value: 0 },
  { label: 'Papers', value: 0 },
]);

const chartRef = ref(null);
let chartInstance = null;
let resizeHandler = null;
const chartData = ref([]);

const renderChart = (data) => {
  if (!chartRef.value) return;
  if (!data || data.length === 0) return;
  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value);
  }
  const option = {
    tooltip: { trigger: 'item' },
    legend: { top: 'bottom' },
    series: [
      {
        name: 'Algorithms',
        type: 'pie',
        radius: '60%',
        data: data.map((d) => ({ value: d.algorithm_count, name: d.problem_name })),
        label: { formatter: '{b}: {c}' },
      },
    ],
  };
  chartInstance.setOption(option);
};

const loadStats = async () => {
  const stats = await fetchStats();
  statCards.value = [
    { label: 'Algorithms', value: stats.algorithm_count ?? 0 },
    { label: 'Tools', value: stats.tool_count ?? 0 },
    { label: 'Papers', value: stats.paper_count ?? 0 },
  ];
  chartData.value = stats.algorithm_by_problem || [];
  await nextTick();
  renderChart(chartData.value);
};

// 当分类数据变化时，DOM 已渲染则再次绘制
watch(chartData, async (val) => {
  if (!val || val.length === 0) return;
  await nextTick();
  renderChart(val);
});

onMounted(() => {
  loadStats();
  resizeHandler = () => chartInstance?.resize();
  window.addEventListener('resize', resizeHandler);
});

onBeforeUnmount(() => {
  if (resizeHandler) window.removeEventListener('resize', resizeHandler);
  chartInstance?.dispose();
  chartInstance = null;
});
</script>

<style scoped>
.home {
  padding: 24px;
}
.hero {
  text-align: center;
  margin-bottom: 24px;
}
.hero h1 {
  margin: 0;
  font-size: 32px;
}
.hero p {
  margin: 8px 0 0;
  color: #555;
}
.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: #f7f9fc;
  border: 1px solid #e5eaf5;
  border-radius: 10px;
  padding: 16px;
  text-align: center;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
}
.stat-label {
  color: #666;
  margin-top: 6px;
}
.chart-section h2 {
  margin-bottom: 12px;
}
.chart {
  height: 360px;
  background: #fff;
  border: 1px solid #e5eaf5;
  border-radius: 10px;
}
.chart-placeholder {
  height: 360px;
  background: #fff;
  border: 1px solid #e5eaf5;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #666;
  font-size: 14px;
}
</style>
