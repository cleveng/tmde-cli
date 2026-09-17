<script setup lang="ts">
import { useQuery } from '@urql/vue'
import { Search, SlidersHorizontal } from 'lucide-vue-next'
import { computed, ref, watch, provide, reactive } from 'vue'
import { useMessage } from 'naive-ui'
import { <@ data.capitalize_name @>Document, type <@ data.capitalize_name @>Query } from '@/generated/graphql'

import <@ data.capitalize_name @>Dialogs from './components/<@ data.name @>-dialogs'
import <@ data.capitalize_name @>PrimaryButton from './components/<@ data.name @>-primary-button'
import <@ data.capitalize_name @>Provider from './components/<@ data.name @>-provider'
import <@ data.capitalize_name @>Table from './components/<@ data.name @>-table'

import type { API } from '/#/api'

defineOptions({
  name: '<@ data.capitalize_name @>Index'
})

const message = useMessage()

const defaultParams = () => ({
  machine_no: null as string | null,
  group_id: null as number | null,
  status: null as number | null,
})

const state = reactive({
  result: {} as API.Page<API.<@ data.pascal_case_name @>>,
  params: defaultParams()
})

const currentPage = ref<number>(1)

const variables = computed(() => ({
  input: {
    ...state.params,
    per_page: 20,
    current_page: currentPage.value
  }
}))

const { fetching, data, executeQuery } = useQuery({
  query: <@ data.capitalize_name @>Document,
  variables,
  requestPolicy: 'cache-and-network'
})

const options = computed(() => {
  return [
  	{
	    label: 'label',
	    value: 1,
	    disabled: true
    }
  ]
})

const refetch = async () => {
  await executeQuery({
    requestPolicy: 'network-only'
  })
}

provide('refetch', refetch)

// 修改分页
const loadMore = async (val: number) => {
  currentPage.value = val
  await refetch()
}

const todo = ref<string[]>([])
provide('todo', todo)

watch(
  data,
  async (values: <@ data.capitalize_name @>Query) => {
    state.result = (values?.<@ data.name @> as unknown as API.Page<API.<@ data.capitalize_name @>>) ?? {
      total: 0,
      currentPage: 1,
      lastPage: 0,
      perPage: 20,
      data: []
    }

    todo.value = []
  },
  { immediate: true, deep: true }
)

const validateInput = (input: string) => {
  const value = input.trim()

  if (!value) {
    state.params.machine_no = null
    return
  }

//  eg: 校验规则
//  if (!isEmail(value)) {
//    message.error('请输入正确的文本内容')
//    return
//  }

  state.params.machine_no = value
}
</script>

<template>
  <<@ data.capitalize_name @>Provider>
  <n-page-header>
      <div class="space-y-4">
        <n-alert type="warning">
          警告标题xxxxxxxxxxxxx
        </n-alert>

        <n-grid x-gap="12" :cols="4">
          <n-gi>
            <n-card title="全部广告">
              <template #header-extra> #header-extra </template>
              <b class="text-4xl">128</b>
              <template #footer> 较上月 +12 </template>
            </n-card>
          </n-gi>
          <n-gi>
            <n-card title="正在投放">
              <template #header-extra> #header-extra </template>
              <b class="text-4xl">36</b>
              <template #footer> 28.1% 投放率 </template>
            </n-card>
          </n-gi>
          <n-gi>
            <n-card title="图片广告">
              <template #header-extra> #header-extra </template>
              <b class="text-4xl">82</b>
              <template #footer> JPG / PNG / WEBP </template>
            </n-card>
          </n-gi>
          <n-gi>
            <n-card title="视频广告">
              <template #header-extra> #header-extra </template>
              <b class="text-4xl">46</b>
              <template #footer> MP4 / WEBM </template>
            </n-card>
          </n-gi>
        </n-grid>

        <n-card :bordered="false">
          <template #header>
            <div></div>
          </template>
          <template #header-extra>
            <n-space :wrap="false" :size="12">
              <n-input
                :default-value="state.params.machine_no"
                size="large"
                type="text"
                clearable
                placeholder="请输入内容"
                @update:value="validateInput"
              >
                <template #prefix>
                  <n-icon :component="Search" />
                </template>
              </n-input>
              <n-popover class="w-96" placement="bottom" trigger="click">
                <template #trigger>
                  <n-button size="large">
                    <template #icon>
                      <n-icon>
                        <SlidersHorizontal />
                      </n-icon>
                    </template>
                    筛选
                  </n-button>
                </template>
                <n-card
                  title="筛选"
                  :segmented="{
                    content: true,
                    footer: 'soft'
                  }"
                  :bordered="false"
                  size="small"
                >
                  <template #header-extra>
                    <n-button size="medium">重置</n-button>
                  </template>
                  <n-form-item label="分组" path="params.group_id">
                    <n-select
                      v-model:value="state.params.group_id"
                      clearable
                      size="large"
                      placeholder="请选择分组"
                      :options="options"
                    />
                  </n-form-item>
                  <n-form-item label="状态" path="params.status">
                    <n-select
                      placeholder=""
                      size="large"
                      clearable
                      :value="state.params.status"
                      :options="options"
                    />
                  </n-form-item>
                </n-card>
              </n-popover>
            </n-space>
          </template>
          <n-spin :show="fetching">
        	  <<@ data.capitalize_name @>Table :result="state.result" :load-more="loadMore" />
          </n-spin>
        </n-card>
      </div>
      <template #title>
        <h4 class="text-2xl">标题占位</h4>
        <p class="hidden text-sm text-gray-400 md:block">副标题占位</p>
      </template>
      <template #extra>
        <<@ data.capitalize_name @>PrimaryButton />
      </template>
    </n-page-header>

    <<@ data.capitalize_name @>Dialogs />
  </<@ data.capitalize_name @>Provider>
</template>
