<script setup lang="ts">
import { useQuery } from '@urql/vue'
import { computed, provide } from 'vue'

import { AccountsDocument } from '@/generated/graphql'

import AccountsDialogs from './components/accounts-dialogs'
import AccountsPrimaryButton from './components/accounts-primary-button'
import AccountsProvider from './components/accounts-provider'
import AccountsTable from './components/accounts-table'

import type { API } from '/#/api'

defineOptions({
  name: 'AccountsIndex'
})

const { fetching, data, executeQuery } = useQuery({
  query: AccountsDocument,
  requestPolicy: 'cache-and-network'
})

const todo = computed(() => [])
provide('todo', todo)

const refetch = async () => {
  await executeQuery({
    requestPolicy: 'network-only'
  })
}

provide('refetch', refetch)
</script>

<template>
  <AccountsProvider>
    <n-card :bordered="false" title="卡片占位标题">
      <template #header-extra>
        <AccountsPrimaryButton />
      </template>
      <n-spin :show="fetching">
        <AccountsTable :items="data?.accounts as unknown as API.Account[]" />
      </n-spin>
    </n-card>

    <AccountsDialogs />
  </AccountsProvider>
</template>
