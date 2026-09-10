<script setup lang="ts">
import { useQuery } from '@urql/vue'
import { computed, provide } from 'vue'

import { <@ data.capitalize_name @>Document } from '@/generated/graphql'

import <@ data.capitalize_name @>Dialogs from './components/<@ data.name @>-dialogs'
import <@ data.capitalize_name @>PrimaryButton from './components/<@ data.name @>-primary-button'
import <@ data.capitalize_name @>Provider from './components/<@ data.name @>-provider'
import <@ data.capitalize_name @>Table from './components/<@ data.name @>-table'

import type { API } from '/#/api'

defineOptions({
  name: '<@ data.capitalize_name @>Index'
})

const { fetching, data, executeQuery } = useQuery({
  query: <@ data.capitalize_name @>Document,
  requestPolicy: 'cache-and-network'
})

const todo = computed(() => string[])
provide('todo', todo)

const refetch = async () => {
  await executeQuery({
    requestPolicy: 'network-only'
  })
}

provide('refetch', refetch)
</script>

<template>
  <<@ data.capitalize_name @>Provider>
    <n-card :bordered="false" title="卡片占位标题">
      <template #header-extra>
        <<@ data.capitalize_name @>PrimaryButton />
      </template>
      <n-spin :show="fetching">
        <<@ data.capitalize_name @>Table :items="data?.<@ data.capitalize_name @> as unknown as API.<@ data.capitalize_name @>[]" />
      </n-spin>
    </n-card>

    <<@ data.capitalize_name @>Dialogs />
  </<@ data.capitalize_name @>Provider>
</template>
